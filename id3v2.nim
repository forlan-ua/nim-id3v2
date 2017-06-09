import strutils, sequtils, streams, encodings

type Id3v2FrameKind* = enum
    AENC,#    [[#sec4.20|Audio encryption]]
    APIC,#    [#sec4.15 Attached picture]
    COMM,#    [#sec4.11 Comments]
    COMR,#    [#sec4.25 Commercial frame]
    ENCR,#    [#sec4.26 Encryption method registration]
    EQUA,#    [#sec4.13 Equalization]
    ETCO,#    [#sec4.6 Event timing codes]
    GEOB,#    [#sec4.16 General encapsulated object]
    GRID,#    [#sec4.27 Group identification registration]
    IPLS,#    [#sec4.4 Involved people list]
    LINK,#    [#sec4.21 Linked information]
    MCDI,#    [#sec4.5 Music CD identifier]
    MLLT,#    [#sec4.7 MPEG location lookup table]
    OWNE,#    [#sec4.24 Ownership frame]
    PRIV,#    [#sec4.28 Private frame]
    PCNT,#    [#sec4.17 Play counter]
    POPM,#    [#sec4.18 Popularimeter]
    POSS,#    [#sec4.22 Position synchronisation frame]
    RBUF,#    [#sec4.19 Recommended buffer size]
    RVAD,#    [#sec4.12 Relative volume adjustment]
    RVRB,#    [#sec4.14 Reverb]
    SYLT,#    [#sec4.10 Synchronized lyric/text]
    SYTC,#    [#sec4.8 Synchronized tempo codes]
    TALB,#    [#TALB Album/Movie/Show title]
    TBPM,#    [#TBPM BPM (beats per minute)]
    TCOM,#    [#TCOM Composer]
    TCON,#    [#TCON Content type]
    TCOP,#    [#TCOP Copyright message]
    TDAT,#    [#TDAT Date]
    TDLY,#    [#TDLY Playlist delay]
    TENC,#    [#TENC Encoded by]
    TEXT,#    [#TEXT Lyricist/Text writer]
    TFLT,#    [#TFLT File type]
    TIME,#    [#TIME Time]
    TIT1,#    [#TIT1 Content group description]
    TIT2,#    [#TIT2 Title/songname/content description]
    TIT3,#    [#TIT3 Subtitle/Description refinement]
    TKEY,#    [#TKEY Initial key]
    TLAN,#    [#TLAN Language(s)]
    TLEN,#    [#TLEN Length]
    TMED,#    [#TMED Media type]
    TOAL,#    [#TOAL Original album/movie/show title]
    TOFN,#    [#TOFN Original filename]
    TOLY,#    [#TOLY Original lyricist(s)/text writer(s)]
    TOPE,#    [#TOPE Original artist(s)/performer(s)]
    TORY,#    [#TORY Original release year]
    TOWN,#    [#TOWN File owner/licensee]
    TPE1,#    [#TPE1 Lead performer(s)/Soloist(s)]
    TPE2,#    [#TPE2 Band/orchestra/accompaniment]
    TPE3,#    [#TPE3 Conductor/performer refinement]
    TPE4,#    [#TPE4 Interpreted, remixed, or otherwise modified by]
    TPOS,#    [#TPOS Part of a set]
    TPUB,#    [#TPUB Publisher]
    TRCK,#    [#TRCK Track number/Position in set]
    TRDA,#    [#TRDA Recording dates]
    TRSN,#    [#TRSN Internet radio station name]
    TRSO,#    [#TRSO Internet radio station owner]
    TSIZ,#    [#TSIZ Size]
    TSRC,#    [#TSRC ISRC (international standard recording code)]
    TSSE,#    [#TSEE Software/Hardware and settings used for encoding]
    TYER,#    [#TYER Year]
    TXXX,#    [#TXXX User defined text information frame]
    UFID,#    [#sec4.1 Unique file identifier]
    USER,#    [#sec4.23 Terms of use]
    USLT,#    [#sec4.9 Unsychronized lyric/text transcription]
    WCOM,#    [#WCOM Commercial information]
    WCOP,#    [#WCOP Copyright/Legal information]
    WOAF,#    [#WOAF Official audio file webpage]
    WOAR,#    [#WOAR Official artist/performer webpage]
    WOAS,#    [#WOAS Official audio source webpage]
    WORS,#    [#WORS Official internet radio station homepage]
    WPAY,#    [#WPAY Payment]
    WPUB,#    [#WPUB Publishers official webpage]
    WXXX, #    [#WXXX User defined URL link frame]
    UNKNOWN


const binaryUnsafe = [
    Id3v2FrameKind.UFID, 
    Id3v2FrameKind.MCDI, 
    Id3v2FrameKind.SYTC, 
    Id3v2FrameKind.APIC, 
    Id3v2FrameKind.GEOB, 
    Id3v2FrameKind.AENC, 
    Id3v2FrameKind.COMR, 
    Id3v2FrameKind.ENCR, 
    Id3v2FrameKind.GRID, 
    Id3v2FrameKind.PRIV,
    Id3v2FrameKind.UNKNOWN
]

const multiple = [
    Id3v2FrameKind.TXXX,
    Id3v2FrameKind.WXXX,
    Id3v2FrameKind.PRIV,
    Id3v2FrameKind.UNKNOWN
]


type Id3v2FrameId = object
    kind: Id3v2FrameKind
    str: string

proc `$`*(fi: Id3v2FrameId): string = fi.str


type Id3v2Version* {.pure.} = enum
    v22 = 2.int8
    v23 = 3.int8
    v24 = 4.int8


type Id3v2TagFlag* {.pure.} = enum
    experimentalIndicator = 1 shl 5
    extendedHeader = 1 shl 6
    unsynchronisation = 1 shl 7


type Id3v2FrameFlag* {.pure.} = enum
    groupingIdentity = 1 shl 5
    encryption = 1 shl 6
    compression = 1 shl 7
    readOnly = 1 shl 13
    fileAlterPreservation = 1 shl 14
    tagAlterPreservation = 1 shl 15


type Id3v2Frame* = ref object
    id: Id3v2FrameId
    value: string
    size: int
    flags: int
    binaryUnsafe: bool
    multiple: bool


type Id3v2Tag* = ref object
    version: Id3v2Version
    frames: seq[Id3v2Frame]
    size: int
    flags: int


proc newId3v2Tag*(): Id3v2Tag = 
    Id3v2Tag(
        version: Id3v2Version.v24, 
        frames: @[]
    )


proc getSize(s: Stream): int =
    s.readInt8().int shl 21 + s.readInt8().int shl 14 + s.readInt8().int shl 7 + s.readInt8().int


proc newId3v2Tag*(stream: Stream): Id3v2Tag =
    result = newId3v2Tag()

    if not stream.isNil:
        let idv3HeaderMarker = stream.readStr(3)
        if idv3HeaderMarker == "ID3":
            result.version = stream.readInt8().Id3v2Version
            discard stream.readInt8() # subversion

            result.flags = stream.readInt8().int
            result.size = getSize(stream)
            var size = result.size

            while size > 10:
                let frameId = stream.readStr(4)

                if not frameId.isAlphaNumeric():
                    size -= 4
                    continue

                let frame = Id3v2Frame()

                var frameSize = getSize(stream)
                frame.size = frameSize
                frame.flags = stream.readInt8().int shl 8 + stream.readInt8().int

                size -= 10 + frameSize

                try:
                    frame.id = Id3v2FrameId(kind: parseEnum[Id3v2FrameKind](frameId), str: frameId)
                except:
                    if frameId[0] == 'T':
                        frame.id = Id3v2FrameId(kind: Id3v2FrameKind.TXXX, str: frameId)
                    elif frameId[0] == 'W':
                        frame.id = Id3v2FrameId(kind: Id3v2FrameKind.WXXX, str: frameId)
                    else:
                        frame.id = Id3v2FrameId(kind: Id3v2FrameKind.UNKNOWN, str: frameId)

                frame.binaryUnsafe = frame.id.kind in binaryUnsafe
                
                if frameSize > 0:
                    if frame.binaryUnsafe:
                        frame.value = stream.readStr(frameSize)
                    else:
                        frame.value = stream.readStr(frameSize).replace($char(0b0), "")
                    result.frames.add(frame)

    
proc newId3v2Tag*(filepath: string): Id3v2Tag =
    var stream = newFileStream(filepath, fmRead)
    result = newId3v2Tag(stream)
    stream.close()


proc newId3v2Tag*(file: File): Id3v2Tag =
    var stream = newFileStream(file)
    result = newId3v2Tag(stream)
    stream.close()


let tag = newId3v2Tag("song.mp3")
echo getCurrentEncoding()
let conv = open(destEncoding = "UTF-8", srcEncoding = "UTF-8")
for frame in tag.frames:
    if not frame.binaryUnsafe:
        echo frame.id, " : ", conv.convert(frame.value)