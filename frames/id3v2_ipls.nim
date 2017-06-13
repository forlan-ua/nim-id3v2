import streams
import .. / id3v2_types

import id3v2_t


type Id3v2FrameIPLS* = ref object of Id3v2FrameT


template list*(f: Id3v2FrameIPLS): string =
    return f.data


template `list=`*(f: Id3v2FrameIPLS, s: string) =
    f.size += s.len - f.data.len
    f.data = s


proc newId3v2FrameIPLS*(flags: int16, str: string): Id3v2FrameIPLS =
    newId3v2FrameT(flags, IPLS, str).Id3v2FrameIPLS


proc newId3v2FrameIPLS*(flags: int16, textEncoding: int8, description: string, data: string): Id3v2FrameIPLS =
    newId3v2FrameT(flags, IPLS, textEncoding, data).Id3v2FrameIPLS