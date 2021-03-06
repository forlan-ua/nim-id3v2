import streams


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
    WXXX #    [#WXXX User defined URL link frame]


type Id3v2FrameFlag* = enum
    id3frameGroupingIdentity = 1 shl 5
    id3frameEncryption = 1 shl 6
    id3frameCompression = 1 shl 7
    id3frameReadOnly = 1 shl 13
    id3frameFileAlterPreservation = 1 shl 14
    id3frameTagAlterPreservation = 1 shl 15


type Id3v2Frame* = ref object of RootObj
    case kind*: Id3v2FrameKind:
        of TXXX, WXXX:
            kindStr: string
        else:
            discard
    data*: string
    size*: int
    flags*: int16


proc writeBinaryInt*[T](s: Stream, i: T, mask: int = 255) =
    var len: int;

    if T is int8:
        len = 1
    elif T is int16:
        len = 2
    else:
        len = 4

    for i in 0..<len:
        let shift = len - 1 - i
        s.write(
            (i and (mask shl shift)) shr shift
        )


proc readBinaryInt*(s: Stream, len: int = 4, shift: int = 8): int8 | int16 | int =
    let mask = (1 shl (shift + 1)) - 1
    if len == 1:
        result = s.readInt8() and mask
    elif len == 2:
        result = (s.readInt8() and mask).int16 shl shift + (s.readInt8() and mask).int16
    else:
        result = 0.int
        for i in 0..<len:
            result += (s.readInt8() and mask).int shl (shift * (len - i))


proc writeHeader*(f: Id3v2Frame, s: Stream) =
    case f.kind:
        of TXXX, WXXX:
            s.write(f.kindStr)
        else:
            s.write($f.kind)
    s.writeBinaryInt(f.flags)
    s.writeBinaryInt(f.size)


method writeData*(f: Id3v2Frame, s: Stream) {.base.} =
    f.writeHeader(s)
    s.write(f.data)


type Id3v2FrameBinary* = ref object of Id3v2Frame


method binaryData*(f: Id3v2FrameBinary): string {.base.} =
    return f.data


method `binaryData=`*(f: Id3v2FrameBinary, s: string) {.base.} =
    f.size = s.len
    f.data = s


type Id3v2TagVersion* {.pure.} = enum
    v22 = 2.int8
    v23 = 3.int8
    v24 = 4.int8


type Id3v2TagFlag* = enum
    id3tagExperimentalIndicator = 1 shl 5
    id3tagExtendedHeader = 1 shl 6
    id3tagUnsynchronisation = 1 shl 7
    

type Id3v2Tag* = ref object
    version: Id3v2TagVersion
    subversion: int8
    frames: seq[Id3v2Frame]
    flags: int8


proc size*(t: Id3v2Tag): int =
    result = 0
    for frame in t.frames:
        result += 10 + frame.size


proc writeHeader*(t: Id3v2Tag, s: Stream) =
    s.write("ID3")
    s.write(t.version.int8)
    s.write(t.subversion)
    s.writeBinaryInt(t.size, mask=127)
    s.writeBinaryInt(t.flags)


proc writeData*(t: Id3v2Tag, s: Stream) =
    s.write("ID3")
    s.write(t.version.int8)
    s.write(t.subversion)
    s.writeBinaryInt(t.size, mask=127)
    s.writeBinaryInt(t.flags)

    for frame in t.frames:
        case frame.kind:
            of 
            else:
                frame.writeData(s)