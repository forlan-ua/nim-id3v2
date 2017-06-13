import streams
import .. / id3v2_types

import id3v2_t

type Id3v2FrameTXXX* = ref object of Id3v2FrameT
    frameDescription: string


template description*(f: Id3v2FrameTXXX): string =
    f.frameDescription


template `description=`*(f: Id3v2FrameTXXX, d: string) =
    f.size += d.len - f.frameDescription.len
    f.frameDescription = d


method writeData*(f: Id3v2FrameTXXX, s: Stream) =
    f.writeHeader(s)
    s.write(f.textEncoding.byte)
    s.write(f.frameDescription)
    s.write(0.byte)
    if (f.textEncoding and 1) > 0:
        s.write(0.byte)
    s.write(f.data)


proc newId3v2FrameTXXX*(flags: int16, str: string): Id3v2FrameTXXX =
    let len = str.len
    let textEncoding = str[0].int8

    var i = 1
    while i < len and str[i].byte != 0.byte:
        i.inc
    let description = str[1..<i]
    i.inc
    if (textEncoding and 1) > 0 and str[i].byte == 0.byte:
        i.inc

    Id3v2FrameTXXX(
        kind: TXXX, 
        flags: flags,
        textEncoding: textEncoding,
        frameDescription: description,
        data: str[i..<len], 
        size: len
    )


proc newId3v2FrameTXXX*(flags: int16, textEncoding: int8, description: string, data: string): Id3v2FrameTXXX =
    Id3v2FrameTXXX(
        kind: TXXX, 
        flags: flags, 
        textEncoding: textEncoding, 
        frameDescription: description,
        data: data, 
        size: 1 + description.len + (if (textEncoding and 1) == 0: 1 else : 2) + data.len
    )