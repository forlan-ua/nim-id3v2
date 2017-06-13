import streams
import .. / id3v2_types

import id3v2_txxx


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