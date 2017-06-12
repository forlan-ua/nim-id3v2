import streams
import .. / id3v2_types


type Id3v2FrameAPICType* = enum
    privTypeOther = 0x00.int8
    privTypeIcon = 0x01.int8
    privTypeOtherIcon = 0x02.int8
    privTypeCoverFront = 0x03.int8
    privTypeCoverBack = 0x04.int8
    privTypeLeafletPage = 0x05.int8
    privTypeMedia = 0x06.int8
    privTypeSoloist = 0x07.int8
    privTypeArtist = 0x08.int8
    privTypeConductor = 0x09.int8
    privTypeBand = 0x0A.int8
    privTypeComposer = 0x0B.int8
    privTypeLyricist = 0x0C.int8
    privTypeRecordingLocation = 0x0D.int8
    privTypeDuringRecording = 0x0E.int8
    privTypeDuringPerformance = 0x0F.int8
    privTypeMovieScreenCapture = 0x10.int8
    privTypeColoured = 0x11.int8
    privTypeIllustration = 0x12.int8
    privTypeBandLogo = 0x13.int8
    privTypePublisherLogo = 0x14.int8


proc describe*(t: Id3v2FrameAPICType): string =
    case t:
        of privTypeOther: "Other"
        of privTypeIcon: "32x32 pixels 'file icon' (PNG only)"
        of privTypeOtherIcon: "Other file icon"
        of privTypeCoverFront: "Cover (front)"
        of privTypeCoverBack: "Cover (back)"
        of privTypeLeafletPage: "Leaflet page"
        of privTypeMedia: "Media (e.g. lable side of CD)"
        of privTypeSoloist: "Lead artist/lead performer/soloist"
        of privTypeArtist: "Artist/performer"
        of privTypeConductor: "Conductor"
        of privTypeBand: "Band/Orchestra"
        of privTypeComposer: "Composer"
        of privTypeLyricist: "Lyricist/text writer"
        of privTypeRecordingLocation: "Recording Location"
        of privTypeDuringRecording: "During recording"
        of privTypeDuringPerformance: "During performance"
        of privTypeMovieScreenCapture: "Movie/video screen capture"
        of privTypeColoured: "A bright coloured fish"
        of privTypeIllustration: "Illustration"
        of privTypeBandLogo: "Band/artist logotype"
        of privTypePublisherLogo: "Publisher/Studio logotype"


type Id3v2FrameAPIC* = ref object of Id3v2FrameBinary
    textEncoding*: int8
    mimeType*: string
    pictureType*: Id3v2FrameAPICType
    description*: string


method `binaryData=`*(f: Id3v2FrameAPIC, d: string) =
    f.size += d.len - f.data.len
    f.data = d


method writeData*(f: Id3v2FrameAPIC, s: Stream) =
    f.writeHeader(s)
    s.writeBinaryInt(f.textEncoding)
    s.write(f.mimeType)
    s.write(0b0.byte)
    s.writeBinaryInt(f.pictureType.int8)
    s.write(f.description)
    s.write(0b0.byte)
    if (f.textEncoding and 1) != 0:
        s.write(0b0.byte)
    s.write(f.binaryData)


proc newId3v2FrameAPIC*(flags: int16, str: string): Id3v2FrameAPIC =
    let textEncoding = str[0].int8
    let len = str.len
    var j = 1

    var i = 1
    while j < len and str[j].byte != 0b0.byte:
        j.inc
    let mimeType = str[i..<j]
    j.inc

    let pictureType = str[j].Id3v2FrameAPICType
    j.inc

    i = j
    while j < len and str[j].byte != 0b0.byte:
        j.inc
    let description = str[i..<j]
    j.inc
    if (textEncoding and 1) == 0 and str[j].byte == 0b0.byte:
        j.inc

    Id3v2FrameAPIC(
        kind: APIC, 
        flags: flags, 
        textEncoding: textEncoding, 
        mimeType: mimeType, 
        pictureType: pictureType,
        description: description,
        data: str[j..<len],
        size: len
    )


proc newId3v2FrameAPIC*(flags: int16, textEncoding: int8, mimeType: string, pictureType: Id3v2FrameAPICType, description: string, data: string): Id3v2FrameAPIC =
    Id3v2FrameAPIC(
        kind: APIC, 
        flags: flags, 
        textEncoding: textEncoding, 
        mimeType: mimeType, 
        pictureType: pictureType,
        description: description,
        data: data,
        size: 1 + mimeType.len + 1 + 1 + description.len + (if (textEncoding and 1) == 0: 1 else: 2) + data.len
    )