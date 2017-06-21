import streams, times
import .. / id3v2_types


type Id3v2FrameCOMRType* = enum
    other = 0.int8
    standartCD = 1.int8
    compressedAudio = 2.int8
    internetFile = 3.int8
    internerStream = 4.int8
    noteSheets = 5.int8
    noteSheetBook = 6.int8
    musicOnOtherMedia = 7.int
    nonMusical = 8.int


template describe*(t: Id3v2FrameCOMRType): string =
    case t:
        of other: "Other"
        of standartCD: "Standard CD album with other songs"
        of compressedAudio: "Compressed audio on CD"
        of internetFile: "File over the Internet"
        of internerStream: "Stream over the Internet"
        of noteSheets: "As note sheets"
        of noteSheetBook: "As note sheets in a book with other sheets"
        of musicOnOtherMedia: "Music on other media"
        of nonMusical: "Non-musical merchandise"


type Id3v2FrameCOMR* = ref object of Id3v2FrameBinary
    textEncoding*: int8
    validUntil*: TimeInfo
    receivedAs*: Id3v2FrameCOMRType

    framePriceString: string
    frameContactUrl: string
    frameNameOfSeller: string
    frameDescription: string
    framePictureMimeType: string
    frameSellerLogo: string


template priceString*(f: Id3v2FrameCOMR): string = f.framePriceString
template `priceString=`*(f: Id3v2FrameCOMR, priceString: string) =
    f.size += priceString.len - f.framePriceString.len
    f.framePriceString = priceString


template contactUrl*(f: Id3v2FrameCOMR): string = f.frameContactUrl
template `contactUrl=`*(f: Id3v2FrameCOMR, contactUrl: string) =
    f.size += contactUrl.len - f.frameContactUrl.len
    f.frameContactUrl = contactUrl


template nameOfSeller*(f: Id3v2FrameCOMR): string = f.frameNameOfSeller
template `nameOfSeller=`*(f: Id3v2FrameCOMR, nameOfSeller: string) =
    f.size += nameOfSeller.len - f.frameNameOfSeller.len
    f.frameNameOfSeller = nameOfSeller


template description*(f: Id3v2FrameCOMR): string = f.frameDescription
template `description=`*(f: Id3v2FrameCOMR, description: string) =
    f.size += description.len - f.frameDescription.len
    f.frameDescription = description


template pictureMimeType*(f: Id3v2FrameCOMR): string = f.framePictureMimeType
template `pictureMimeType=`*(f: Id3v2FrameCOMR, pictureMimeType: string) =
    f.size += pictureMimeType.len - f.framePictureMimeType.len
    f.framePictureMimeType = pictureMimeType


template sellerLogo*(f: Id3v2FrameCOMR): string = f.frameSellerLogo
template `sellerLogo=`*(f: Id3v2FrameCOMR, sellerLogo: string) =
    f.size += sellerLogo.len - f.frameSellerLogo.len
    f.frameSellerLogo = sellerLogo


method writeData*(f: Id3v2FrameCOMR, s: Stream) =
    f.writeHeader(s)
    s.write(f.textEncoding.byte)
    s.write(f.framePriceString)
    s.write(0.byte)
    s.write(f.validUntil.format("yyyyMMdd"))
    s.write(f.frameContactUrl)
    s.write(0.byte)
    s.write(f.receivedAs.int8.byte)
    s.write(f.frameNameOfSeller)
    s.write(0.byte)
    if (f.textEncoding and 1) > 0:
        s.write(0.byte)
    s.write(f.frameDescription)
    s.write(0.byte)
    if (f.textEncoding and 1) > 0:
        s.write(0.byte)
    s.write(f.framePictureMimeType)
    s.write(0.byte)
    s.writeBinaryInt(f.data)


proc newId3v2FrameCOMR*(flags: int16, str: string): Id3v2FrameCOMR =
    let len = str.len

    var j = 1
    var i = 1
    while j < len and str[j].byte != 0.byte:
        j.inc
    let framePriceString = str[i..<j]
    j.inc

    i = j
    j.inc(8)
    result = Id3v2FrameCOMR(
        kind: COMR,
        flags: flags,
        size: len,
        textEncoding: str[0].int8,
        framePriceString: framePriceString,
        validUntil: str[i..<j].parse("yyyyMMdd")
    )

    i = j
    while j < len and str[j].byte != 0.byte:
        j.inc
    result.frameContactUrl = str[i..<j]
    j.inc

    result.receivedAs = str[j].Id3v2FrameCOMRType
    j.inc

    i = j
    while j < len and str[j].byte != 0.byte:
        j.inc
    result.frameNameOfSeller = str[i..<j]
    j.inc
    if str[j].byte == 0.byte:
        j.inc

    i = j
    while j < len and str[j].byte != 0.byte:
        j.inc
    result.frameDescription = str[i..<j]
    j.inc
    if str[j].byte == 0.byte:
        j.inc

    i = j
    while j < len and str[j].byte != 0.byte:
        j.inc
    result.framePictureMimeType = str[i..<j]
    j.inc
    
    result.frameSellerLogo = str[j..<len]


proc newId3v2FrameCOMR*(flags: int16, textEncoding: int8, validUntil: TimeInfo, receivedAs: Id3v2FrameCOMRType, priceString: string, contactUrl: string, nameOfSeller: string, description: string, pictureMimeType: string, sellerLogo: string): Id3v2FrameCOMR =
    Id3v2FrameCOMR(
        kind: COMR, 
        flags: flags, 
        textEncoding: textEncoding,
        validUntil: validUntil,
        receivedAs: receivedAs,
        framePriceString: priceString,
        frameContactUrl: contactUrl,
        frameNameOfSeller: nameOfSeller,
        frameDescription: description,
        framePictureMimeType: pictureMimeType,
        frameSellerLogo: sellerLogo,
        size: 1 + (priceString.len + 1) + 8 + (contactUrl.len + 1) + 1 + (nameOfSeller.len + 1 + (textEncoding and 1)) + (description.len + 1 + (textEncoding and 1)) + pictureMimeType.len + 1 + sellerLogo.len
    )