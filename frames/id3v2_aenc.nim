import streams
import .. / id3v2_types


type Id3v2FrameAENC* = ref object of Id3v2FrameBinary
    previewStart*: int16
    previewEnd*: int16

    frameOwner: string


template owner*(f: Id3v2FrameAENC): string = f.frameOwner
template `owner=`*(f: Id3v2FrameAENC, owner: string) =
    f.size += owner.len - f.frameOwner.len
    f.frameOwner = owner


method writeData*(f: Id3v2FrameAENC, s: Stream) =
    f.writeHeader(s)
    s.write(f.frameOwner)
    s.write(0.byte)
    s.writeBinaryInt(f.frameOwner)
    s.writeBinaryInt(f.previewEnd)
    s.write(f.data)


proc newId3v2FrameAENC*(flags: int16, str: string): Id3v2FrameAENC =
    let len = str.len
    result = Id3v2FrameAENC(
        kind: AENC, 
        flags: flags,
        size: len
    )

    var i = 0
    while i < len and str[i].byte != 0.byte:
        i.inc
    result.frameOwner = str[0..<i]
    i.inc

    result.previewStart = (str[i].int8 shl 8) + str[i + 1].int8
    i.inc(2)

    result.previewEnd = (str[i].int8 shl 8) + str[i + 1].int8
    i.inc(2)

    result.data = str[i..<len]


proc newId3v2FrameAENC*(flags: int16, frameOwner: string, previewStart: int16, previewEnd: int16, data: string): Id3v2FrameAENC =
    Id3v2FrameAENC(
        kind: AENC, 
        flags: flags, 
        frameOwner: frameOwner, 
        previewStart: previewStart,
        previewEnd: previewEnd,
        data: data, 
        size: (frameOwner.len + 1) + 2 + 2 + data.len
    )