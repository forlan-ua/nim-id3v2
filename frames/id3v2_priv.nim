import streams
import .. / id3v2_types


type Id3v2FramePRIV* = ref object of Id3v2FrameBinary
    frameOwner: string


template owner*(f: Id3v2FramePRIV): string =
    f.frameOwner


template `owner=`*(f: Id3v2FramePRIV, o: string) =
    f.size += o.len - f.frameOwner.len
    f.owner = o


method `binaryData=`*(f: Id3v2FramePRIV, d: string) =
    f.size += d.len - f.data.len
    f.data = d


method writeData*(f: Id3v2FramePRIV, s: Stream) =
    f.writeHeader(s)
    s.write(f.owner)
    s.write(0b0.byte)
    s.write(f.binaryData)


proc newId3v2FramePRIV*(flags: int16, str: string): Id3v2FramePRIV =
    var i = 0
    let len = str.len
    while i < len and str[i].byte != 0b0.byte:
        i.inc
        
    Id3v2FramePRIV(
        kind: PRIV, 
        flags: flags, 
        frameOwner: str[0..<i], 
        data: str[i+1..<len], 
        size: len
    )


proc newId3v2FramePRIV*(flags: int16, owner: string, data: string): Id3v2FramePRIV =
    Id3v2FramePRIV(
        kind: PRIV, 
        flags: flags, 
        frameOwner: owner, 
        data: data, 
        size: owner.len + 1 + data.len
    )