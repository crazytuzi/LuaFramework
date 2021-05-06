ZZRc4 = {}

function ZZRc4.encrypt(text,key)
    local function KSA(key)
        local keyLen = string.len(key)
        local schedule = {}
        local keyByte = {}
        for i = 0, 255 do
            schedule[i] = i
        end

        for i = 1, keyLen do
            keyByte[i - 1] = string.byte(key, i, i)
        end

        local j = 0
        for i = 0, 255 do
            j = (j + schedule[i] + keyByte[ i % keyLen]) % 256
            schedule[i], schedule[j] = schedule[j], schedule[i]
        end
        return schedule
    end

    local function PRGA(schedule, textLen)
        local i = 0
        local j = 0
        local k = {}
        for n = 1, textLen do
            i = (i + 1) % 256
            j = (j + schedule[i]) % 256
            schedule[i], schedule[j] = schedule[j], schedule[i]
            k[n] = schedule[(schedule[i] + schedule[j]) % 256]
        end
        return k
    end

    local function output(schedule, text)
        local len = string.len(text)
        local c = nil
        local res = {}
        for i = 1, len do
            c = string.byte(text, i,i)
            res[i] = string.char(MathBit.xorOp(schedule[i], c))
        end

        return table.concat(res)
    end

    local textLen = string.len(text)
    local schedule = KSA(key)
    local k = PRGA(schedule, textLen)
    return output(k, text)
end
