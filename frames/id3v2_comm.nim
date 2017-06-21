import streams, strutils
import .. / id3v2_types
import id3v2_t


type Id3v2FrameCOMM = ref object of Id3v2FrameT
    frameLanguage: string
    frameShortDescription: string


template language*(f: Id3v2FrameCOMM): string = f.frameLanguage
template `language=`*(f: Id3v2FrameCOMM, language: string) =
    var lang = language
    if lang.len != 3:
        lang = "eng"
    f.frameLanguage = lang.toLowerAscii()


template shortDescription*(f: Id3v2FrameCOMM): string = f.frameShortDescription
template `shortDescription=`*(f: Id3v2FrameCOMM, shortDescription: string) =
    f.size += shortDescription.len - f.frameShortDescription.len
    f.frameShortDescription = shortDescription


method writeData*(f: Id3v2FrameCOMM, s: Stream) =
    f.writeHeader(s)
    s.write(f.textEncoding.byte)
    s.write(f.frameLanguage)
    s.write(f.frameShortDescription)
    s.write(0.byte)
    s.writeBinaryInt(f.data)


proc newId3v2FrameCOMM*(flags: int16, str: string): Id3v2FrameCOMM =
    let len = str.len
    result = Id3v2FrameCOMM(
        kind: COMM, 
        flags: flags, 
        size: len,
        textEncoding: str[0].int8,
        frameLanguage: str[1..3]
    )

    var i = 4
    while i < len and str[i].byte != 0.byte:
        i.inc
    result.data = str[4..<i]


proc newId3v2FrameCOMM*(flags: int16, textEncoding: int8, language: string, shortDescription: string, data: string): Id3v2FrameCOMM =
    result = Id3v2FrameCOMM(
        kind: COMM, 
        flags: flags, 
        textEncoding: textEncoding,
        frameShortDescription: shortDescription,
        data: data, 
        size: 1 + 3 + shortDescription.len + 1 + data.len
    )
    result.language = language