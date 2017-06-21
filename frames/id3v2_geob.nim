import streams, times
import .. / id3v2_types


type Id3v2FrameGEOB* = ref object of Id3v2FrameBinary
    textEncoding*: int8
    
    frameMimeType: string
    frameFileName: string
    frameDescription: string


template mimeType*(f: Id3v2FrameGEOB): string = f.frameMimeType
template `mimeType=`*(f: Id3v2FrameGEOB, mimeType: string) =
    f.size += mimeType.len - f.frameMimeType.len
    f.frameMimeType = mimeType


template fileName*(f: Id3v2FrameGEOB): string = f.frameFileName
template `fileName=`*(f: Id3v2FrameGEOB, fileName: string) =
    f.size += fileName.len - f.frameFileName.len
    f.frameFileName = fileName


template description*(f: Id3v2FrameGEOB): string = f.frameDescription
template `description=`*(f: Id3v2FrameGEOB, description: string) =
    f.size += description.len - f.frameDescription.len
    f.frameDescription = description


method writeData*(f: Id3v2FrameGEOB, s: Stream) =
    f.writeHeader(s)
    s.write(f.textEncoding.byte)
    s.write(f.frameMimeType)
    s.write(0.byte)
    s.write(f.frameFileName)
    s.write(0.byte)
    if (f.textEncoding and 1) == 1:
        s.write(0.byte)
    s.write(f.frameDescription)
    s.write(0.byte)
    if (f.textEncoding and 1) == 1:
        s.write(0.byte)
    s.write(f.data)


proc newId3v2FrameGEOB*(flags: int16, str: string): Id3v2FrameGEOB =
    let len = str.len
    result = Id3v2FrameGEOB(
        kind: GEOB, 
        flags: flags,
        textEncoding: str[0].int8,
        size: len
    )

    var i = 1
    var j = 1

    i = j
    while j < len and str[j].byte != 0.byte:
        j.inc
    result.frameMimeType = str[i..<j]
    j.inc

    i = j
    while j < len and str[j].byte != 0.byte:
        j.inc
    result.frameFileName = str[i..<j]
    j.inc
    if str[j].byte == 0.byte:
        j.inc

    i = j
    while j < len and str[j].byte != 0.byte:
        j.inc
    result.frameDescription = str[i..<j]
    j.inc
    if str[j].byte == 0.byte:
        j.inc

    result.data = str[j..<len]


proc newId3v2FrameGEOB*(flags: int16, textEncoding: int8, mimeType: string, fileName: string, description: string, data: string): Id3v2FrameGEOB =
    result = Id3v2FrameGEOB(
        kind: ENCR,
        flags: flags,
        textEncoding: textEncoding,
        frameMimeType: mimeType,
        frameFileName: fileName,
        frameDescription: description,
        data: data,
        size: 1 + (mimeType.len + 1) + (fileName.len + 1 + (textEncoding and 1)) + (description.len + 1 + (textEncoding and 1)) + data.len
    )