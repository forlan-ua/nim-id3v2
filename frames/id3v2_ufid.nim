import streams
import .. / id3v2_types
import id3v2_priv



type Id3v2FrameUFID* = ref object of Id3v2FramePRIV


proc newId3v2FrameUFID*(flags: int16, str: string): Id3v2FrameUFID =
    newId3v2FramePRIV(flags, str).Id3v2FrameUFID


proc newId3v2FrameUFID*(flags: int16, owner: string, data: string): Id3v2FrameUFID =
    newId3v2FramePRIV(flags, owner, data).Id3v2FrameUFID