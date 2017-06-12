import streams
import .. / id3v2_types

import id3v2_text


type Id3v2FrameLink* = ref object of Id3v2Frame


template url*(f: Id3v2FrameLink): string =
    return f.data


template `url=`*(f: Id3v2FrameLink, s: string) =
    f.size += s.len - f.data.len
    f.data = s


proc newId3v2FrameLink*(flags: int16, kind: Id3v2FrameKind, str: string): Id3v2FrameLink =
    Id3v2FrameLink(
        kind: kind, 
        flags: flags,
        data: str, 
        size: str.len
    )


proc newId3v2FrameLink*(flags: int16, kind: Id3v2FrameKind, data: string): Id3v2FrameLink =
    Id3v2FrameLink(
        kind: kind, 
        flags: flags,
        data: data, 
        size: data.len
    )


type Id3v2FrameWXXX* = ref object of Id3v2FrameTXXX


template url*(f: Id3v2FrameWXXX): string =
    return f.data


template `url=`*(f: Id3v2FrameWXXX, s: string) =
    f.size += s.len - f.data.len
    f.data = s


proc newId3v2FrameWXXX*(flags: int16, str: string): Id3v2FrameWXXX =
    newId3v2FrameTXXX(flags, str).Id3v2FrameWXXX


proc newId3v2FrameWXXX*(flags: int16, textEncoding: int8, description: string, data: string): Id3v2FrameWXXX =
    newId3v2FrameTXXX(flags, textEncoding, description, data).Id3v2FrameWXXX