import streams, times
import .. / id3v2_types


type Id3v2FrameENCR* = ref object of Id3v2FrameBinary
    methodSymbol*: int8
    
    frameOwnerIdentifier: string


template ownerIdentifier*(f: Id3v2FrameENCR): string = f.frameOwnerIdentifier
template `ownerIdentifier=`*(f: Id3v2FrameENCR, ownerIdentifier: string) =
    f.size += ownerIdentifier.len - f.frameOwnerIdentifier.len
    f.frameOwnerIdentifier = ownerIdentifier


method writeData*(f: Id3v2FrameENCR, s: Stream) =
    f.writeHeader(s)
    s.write(f.frameOwnerIdentifier)
    s.write(0.byte)
    s.write(f.methodSymbol.byte)
    s.write(f.data)


proc newId3v2FrameENCR*(flags: int16, str: string): Id3v2FrameENCR =
    let len = str.len
    result = Id3v2FrameENCR(
        kind: ENCR, 
        flags: flags, 
        size: len
    )

    var j = 0
    while j < len and str[j].byte != 0.byte:
        j.inc
    result.frameOwnerIdentifier = str[0..<j]
    j.inc

    result.methodSymbol = str[j].int8
    j.inc

    result.data = str[j..<len]


proc newId3v2FrameENCR*(flags: int16, ownerIdentifier: string, methodSymbol: int8, data: string): Id3v2FrameENCR =
    result = Id3v2FrameENCR(
        kind: ENCR, 
        flags: flags,
        frameOwnerIdentifier: ownerIdentifier,
        methodSymbol: methodSymbol,
        data: data, 
        size: (ownerIdentifier.len + 1) + 1 + data.len
    )