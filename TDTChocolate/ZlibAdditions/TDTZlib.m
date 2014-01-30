#import "TDTZlib.h"
#include <zlib.h>

NSString *const TDTZlibCompressorException = @"TDTZlibCompressorException";
NSString *const TDTZlibDecompressorException = @"TDTZlibDecompressorException";

NSString *const TDTZlibExceptionCodeKey = @"TDTZlibExceptionCodeKey";

#define OUTBUFFER_CHUNK_SIZE_DEFAULT 2048
#define DEFAULT_WINDOW_SIZE 15
#define READ_CHUNK_SIZE 4096 // in bytes

@interface TDTZlibCompressor ()

@property (nonatomic) NSMutableData *outBuffer;
@property (nonatomic) TDTCompressionFormat compressionFormat;
@property (nonatomic) z_streamp zStream;
@property (nonatomic) BOOL isZStreamInitialized;

@end


@implementation TDTZlibCompressor

+ (NSException *)exceptionWithCode:(int)code msg:(const char *)msg {
  return [NSException exceptionWithName:TDTZlibCompressorException
                                 reason:@(msg)
                               userInfo:@{TDTZlibExceptionCodeKey: @(code)}];
}

- (id)initWithCompressionFormat:(TDTCompressionFormat)compressionFormat level:(int)level {
  self = [super init];
  if (self) {
    _isZStreamInitialized = NO;
    _compressionFormat = compressionFormat;
    _outBufferChunkSize = OUTBUFFER_CHUNK_SIZE_DEFAULT;
    _copyOutputData = YES;
    z_streamp zStream = _zStream = (z_streamp)malloc(sizeof(z_stream));
    zStream->zalloc = Z_NULL;
    zStream->zfree = Z_NULL;
    zStream->opaque = NULL;
    _level = level;
    _windowSize = 15;
  }
  return self;
}

- (id)initWithCompressionFormat:(TDTCompressionFormat)compressionFormat {
  return [self initWithCompressionFormat:compressionFormat level:Z_DEFAULT_COMPRESSION];
}

- (void)dealloc {
  if (_isZStreamInitialized) {
    deflateEnd(_zStream);
  }
  free(_zStream);
}

- (void)initializeZStream {
  int windowBits = (self.compressionFormat == TDTCompressionFormatDeflate) ? self.windowSize : (self.windowSize + 16);
  int result = deflateInit2(self.zStream, self.level, Z_DEFLATED, windowBits, 8, Z_DEFAULT_STRATEGY);
  if (result != Z_OK) {
    @throw [[self class] exceptionWithCode : result msg : self.zStream->msg];
  }
  self.isZStreamInitialized = YES;
}

- (NSData *)compressFlush:(int)flush {
  z_streamp zStream = self.zStream;
  unsigned int outBufferChunkSize = self.outBufferChunkSize;
  zStream->next_out = [self.outBuffer mutableBytes];
  zStream->avail_out = outBufferChunkSize;
  NSUInteger bytesCompressed = 0;
  do {
    if (zStream->avail_out == 0) {
      // insufficient output -- increase size of output buffer
      NSUInteger previousLength = [self.outBuffer length];
      [self.outBuffer increaseLengthBy:outBufferChunkSize];
      zStream->next_out = [self.outBuffer mutableBytes] + previousLength;
      zStream->avail_out = outBufferChunkSize;
    }
    int result = deflate(zStream, flush);
    if (result != Z_OK && result != Z_STREAM_END) {
      @throw [[self class] exceptionWithCode : result msg : zStream->msg];
    }
    bytesCompressed += (outBufferChunkSize - zStream->avail_out);
  } while (zStream->avail_out == 0);
  if (self.copyOutputData) {
    return [NSData dataWithBytes:[self.outBuffer mutableBytes] length:bytesCompressed];
  } else {
    return [NSData dataWithBytesNoCopy:[self.outBuffer mutableBytes] length:bytesCompressed freeWhenDone:NO];
  }
}

- (NSData *)compressData:(NSData *)data flush:(int)flush {
  // This assertion is added because zStream can be sent at most UINT_MAX bytes at a time
  NSAssert((data == nil) || [data length] <= UINT_MAX, @"data length exceeds UINT_MAX: %lu", (unsigned long)[data length]);
  if (!self.isZStreamInitialized) {
    [self initializeZStream];
  }
  self.outBuffer = [NSMutableData dataWithLength:self.outBufferChunkSize];
  if (data != nil) {
    z_streamp zStream = self.zStream;
    zStream->next_in = (Bytef *)[data bytes];
    zStream->avail_in = (unsigned int)[data length];
  }
  return [self compressFlush:flush];
}

- (NSData *)compressData:(NSData *)data {
  return [self compressData:data flush:Z_NO_FLUSH];
}

- (NSData *)flushData:(NSData *)data {
  NSData *output = [self compressData:data flush:Z_SYNC_FLUSH];
  return output;
}

- (NSData *)finishData:(NSData *)data {
  NSData *output = [self compressData:data flush:Z_FINISH];
  int result = deflateEnd(self.zStream);
  if (result != Z_OK) {
    @throw [[self class] exceptionWithCode : result msg : self.zStream->msg];
  }
  return output;
}

- (NSData *)compressFile:(NSString *)path format:(TDTCompressionFormat)format error:(NSError **)error {
  NSInputStream *inStream = [NSInputStream inputStreamWithFileAtPath:path];
  [inStream open];
  uint8_t inBuffer[READ_CHUNK_SIZE];
  NSData *inData;
  NSMutableData *outData = [NSMutableData data];
  do {
    NSInteger length = [inStream read:inBuffer maxLength:READ_CHUNK_SIZE];
    if (length < 0) {
      // Some error with reading data
      if (error != NULL) {
        *error = [inStream streamError];
      }
      return nil;
    } else {
      inData = [NSData dataWithBytes:inBuffer length:(NSUInteger)length];
      if ([inData length] > 0) {
        [outData appendData:[self compressData:inData]];
      }
    }
  } while ([inStream hasBytesAvailable]);
  [inStream close];
  [outData appendData:[self finishData:nil]];
  return outData;
}

@end


@interface TDTZlibDecompressor ()

@property (nonatomic) NSMutableData *outBuffer;
@property (nonatomic) TDTCompressionFormat compressionFormat;
@property (nonatomic) z_streamp zStream;
@property (nonatomic) BOOL isZStreamInitialized;

@end


@implementation TDTZlibDecompressor

+ (NSException *)exceptionWithCode:(int)code msg:(const char *)msg {
  return [NSException exceptionWithName:TDTZlibDecompressorException
                                 reason:@(msg)
                               userInfo:@{TDTZlibExceptionCodeKey: @(code)}];
}

- (id)initWithCompressionFormat:(TDTCompressionFormat)compressionFormat {
  self = [super init];
  if (self) {
    _isZStreamInitialized = NO;
    _compressionFormat = compressionFormat;
    _outBufferChunkSize = OUTBUFFER_CHUNK_SIZE_DEFAULT;
    _copyOutputData = YES;
    z_streamp zStream = _zStream = (z_streamp)malloc(sizeof(z_stream));
    zStream->zalloc = Z_NULL;
    zStream->zfree = Z_NULL;
    zStream->opaque = NULL;
    zStream->avail_in = 0;
    zStream->next_in = Z_NULL;
    _windowSize = 15;
  }
  return self;
}

- (void)dealloc {
  if (_isZStreamInitialized) {
    inflateEnd(_zStream);
  }
  free(_zStream);
}

- (void)initializeZStream {
  int windowBits = (self.compressionFormat == TDTCompressionFormatDeflate) ? self.windowSize : (self.windowSize + 16);
  int result = inflateInit2(self.zStream, windowBits);
  if (result != Z_OK) {
    @throw [[self class] exceptionWithCode : result msg : self.zStream->msg];
  }
  self.isZStreamInitialized = YES;
}

- (NSData *)decompressFlush:(int)flush {
  z_streamp zStream = self.zStream;
  unsigned int outBufferChunkSize = self.outBufferChunkSize;
  zStream->next_out = [self.outBuffer mutableBytes];
  zStream->avail_out = outBufferChunkSize;
  NSUInteger bytesDecompressed = 0;
  int result;
  do {
    if (zStream->avail_out == 0) {
      // insufficient output -- increase size of output buffer
      NSUInteger previousLength = [self.outBuffer length];
      [self.outBuffer increaseLengthBy:outBufferChunkSize];
      zStream->next_out = [self.outBuffer mutableBytes] + previousLength;
      zStream->avail_out = outBufferChunkSize;
    }
    result = inflate(zStream, flush);
    if (result != Z_OK && result != Z_STREAM_END  && result != Z_BUF_ERROR) {
      @throw [[self class] exceptionWithCode : result msg : zStream->msg];
    }
    bytesDecompressed += (outBufferChunkSize - zStream->avail_out);
  } while (zStream->avail_out == 0);
  if (self.copyOutputData) {
    return [NSData dataWithBytes:[self.outBuffer mutableBytes] length:bytesDecompressed];
  } else {
    return [NSData dataWithBytesNoCopy:[self.outBuffer mutableBytes] length:bytesDecompressed freeWhenDone:NO];
  }
}

- (NSData *)decompressData:(NSData *)data flush:(int)flush {
  // This assertion is added because zStream can be sent at most UINT_MAX bytes at a time
  NSAssert((data == nil) || [data length] <= UINT_MAX, @"data length exceeds UINT_MAX: %lu", (unsigned long)[data length]);
  if (!self.isZStreamInitialized) {
    [self initializeZStream];
  }
  self.outBuffer = [NSMutableData dataWithLength:self.outBufferChunkSize];
  if (data != nil) {
    z_streamp zStream = self.zStream;
    zStream->next_in = (Bytef *)[data bytes];
    zStream->avail_in = (unsigned int)[data length];
  }
  return [self decompressFlush:flush];
}

- (NSData *)decompressData:(NSData *)data {
  return [self decompressData:data flush:Z_NO_FLUSH];
}

- (NSData *)flushData:(NSData *)data {
  NSData *output = [self decompressData:data flush:Z_SYNC_FLUSH];
  return output;
}

- (NSData *)finishData:(NSData *)data {
  NSData *output = [self decompressData:data flush:Z_FINISH];
  int result = inflateEnd(self.zStream);
  if (result != Z_OK) {
    @throw [[self class] exceptionWithCode : result msg : self.zStream->msg];
  }
  return output;
}

- (NSData *)decompressFile:(NSString *)path format:(TDTCompressionFormat)format error:(NSError **)error {
  NSInputStream *inStream = [NSInputStream inputStreamWithFileAtPath:path];
  [inStream open];
  uint8_t inBuffer[READ_CHUNK_SIZE];
  NSData *inData;
  NSMutableData *outData = [NSMutableData data];
  do {
    NSInteger length = [inStream read:inBuffer maxLength:READ_CHUNK_SIZE];
    if (length < 0) {
      // Some error with reading data
      if (error != NULL) {
        *error = [inStream streamError];
      }
      return nil;
    } else {
      inData = [NSData dataWithBytes:inBuffer length:(NSUInteger)length];
      if ([inData length] > 0) {
        [outData appendData:[self decompressData:inData]];
      }
    }
  } while ([inStream hasBytesAvailable]);
  [inStream close];
  [outData appendData:[self finishData:nil]];
  return outData;
}

@end
