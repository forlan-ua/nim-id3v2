import streams
import .. / id3v2_types


type Id3v2FrameT* = ref object of Id3v2Frame
    textEncoding*: int8


template textData*(f: Id3v2FrameT): string =
    return f.data


template `textData=`*(f: Id3v2FrameT, s: string) =
    f.size += s.len - f.data.len
    f.data = s


method writeData*(f: Id3v2FrameT, s: Stream) =
    f.writeHeader(s)
    s.write(f.textEncoding.byte)
    s.write(f.data)


proc newId3v2FrameT*(flags: int16, kind: Id3v2FrameKind, str: string): Id3v2FrameT =
    let len = str.len
    Id3v2FrameT(
        kind: kind, 
        flags: flags,
        textEncoding: str[0].int8, 
        data: str[1..<len], 
        size: len
    )


proc newId3v2FrameT*(flags: int16, kind: Id3v2FrameKind, textEncoding: int8, data: string): Id3v2FrameT =
    Id3v2FrameT(
        kind: kind, 
        flags: flags, 
        textEncoding: textEncoding, 
        data: data, 
        size: 1 + data.len
    )