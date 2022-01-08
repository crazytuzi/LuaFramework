--[[--

Checks whether a file exists.

@param string path
@return boolean

]]
function io.exists(path)
    local file = io.open(path, "r")
    if file then
        io.close(file)
        return true
    end
    return false
end

--[[--

Reads entire file into a string, or return FALSE on failure.

@param string path
@return string

]]
function io.readfile(path)
    return me.FileUtils:getFileDataLua(path,'rb')
end

--[[--

Write a string to a file, or return FALSE on failure.

@param string path
@param string content
@param string mode
@return boolean

### Note:
The mode string can be any of the following:
    "r": read mode
    "w": write mode;
    "a": append mode;
    "r+": update mode, all previous data is preserved;
    "w+": update mode, all previous data is erased; (the default);
    "a+": append update mode, previous data is preserved, writing is only allowed at the end of file.

]]
function io.writefile(path, content, mode)
    mode = mode or "w+"
    local file = io.open(path, mode)
    if file then
        if file:write(content) == nil then return false end
        io.close(file)
        return true
    else
        return false
    end
end

--[[--

Returns information about a file path.

**Usage:**

    local path = "/var/app/test/abc.png"
    local pathinfo  = io.pathinfo(path)
    -- pathinfo.dirname  = "/var/app/test/"
    -- pathinfo.filename = "abc.png"
    -- pathinfo.basename = "abc"
    -- pathinfo.extname  = ".png"


@param string path
@return table

]]
function io.pathinfo(path)
    local pos = string.len(path)
    local extpos = pos + 1
    while pos > 0 do
        local b = string.byte(path, pos)
        if b == 46 then -- 46 = char "."
            extpos = pos
        elseif b == 47 then -- 47 = char "/"
            break
        end
        pos = pos - 1
    end

    local dirname = string.sub(path, 1, pos)
    local filename = string.sub(path, pos + 1)
    extpos = extpos - pos
    local basename = string.sub(filename, 1, extpos - 1)
    local extname = string.sub(filename, extpos)
    return {
        dirname = dirname,
        filename = filename,
        basename = basename,
        extname = extname
    }
end

--[[--

Gets file size, or return FALSE on failure.

@param string path
@return number(integer)

]]
function io.filesize(path)
    local size = false
    local file = io.open(path, "r")
    if file then
        local current = file:seek()
        size = file:seek("end")
        file:seek("set", current)
        io.close(file)
    end
    return size
end