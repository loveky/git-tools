class IndexEntry < BinData::Record
    endian :big

    uint32  :ctime_s
    uint32  :ctime_ns
    uint32  :mtime_s
    uint32  :mtime_ns
    uint32  :dev
    uint32  :ino
    uint32  :mode
    uint32  :uid
    uint32  :gid
    uint32  :file_size
    string  :sha1, :read_length => 20
    uint16  :flags
    stringz :path
end
