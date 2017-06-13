import streams
import .. / id3v2_types

import id3v2_txxx


type Id3v2FrameW* = ref object of Id3v2Frame


template url*(f: Id3v2FrameW): string =
    return f.data


template `url=`*(f: Id3v2FrameW, s: string) =
    f.size += s.len - f.data.len
    f.data = s


proc newId3v2FrameW*(flags: int16, kind: Id3v2FrameKind, str: string): Id3v2FrameW =
    Id3v2FrameW(
        kind: kind, 
        flags: flags,
        data: str, 
        size: str.len
    )


proc newId3v2FrameW*(flags: int16, kind: Id3v2FrameKind, data: string): Id3v2FrameW =
    Id3v2FrameW(
        kind: kind, 
        flags: flags,
        data: data, 
        size: data.len
    )