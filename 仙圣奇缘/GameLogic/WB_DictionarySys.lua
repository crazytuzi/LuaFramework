--------------------------------------------------------------------------------------
-- 文件名:	DictionarySys.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用: vip 
---------------------------------------------------------------------------------------


--[[local bit={data32={}}  
for i=1,32 do  
    bit.data32[i]=2^(32-i)  
end  

--数字转二进制  
function bit:d2b(arg)  
    local   tr={}  
    for i=1,32 do  
        if arg >= self.data32[i] then  
        tr[i]=1  
        arg=arg-self.data32[i]  
        else  
        tr[i]=0  
        end  
    end  
    return   tr  
end   --bit:d2b  

--二进制转数字
function    bit:b2d(arg)  
    local   nr=0  
    for i=1,32 do  
        if arg[i] ==1 then  
        nr=nr+2^(32-i)  
        end  
    end  
    return  nr  
end   --bit:b2d

--与运算
function    bit:_and(a,b)  
    local   op1=self:d2b(a)  
    local   op2=self:d2b(b)  
    local   r={}  
      
    for i=1,32 do  
        if op1[i]==1 and op2[i]==1  then  
            r[i]=1  
        else  
            r[i]=0  
        end  
    end  
    return  self:b2d(r)  
      
end --bit:_and 

function    bit:_xor(a,b)  
    local   op1=self:d2b(a)  
    local   op2=self:d2b(b)  
    local   r={}  
  
    for i=1,32 do  
        if op1[i]==op2[i] then  
            r[i]=0  
        else  
            r[i]=1  
        end  
    end  
    return  self:b2d(r)  
end --bit:xor  
  
function    bit:_or(a,b)  
    local   op1=self:d2b(a)  
    local   op2=self:d2b(b)  
    local   r={}  
      
    for i=1,32 do  
        if  op1[i]==1 or   op2[i]==1   then  
            r[i]=1  
        else  
            r[i]=0  
        end  
    end  
    return  self:b2d(r)  
end --bit:_or  
  
function    bit:_not(a)  
    local   op1=self:d2b(a)  
    local   r={}  
  
    for i=1,32 do  
        if  op1[i]==1   then  
            r[i]=0  
        else  
            r[i]=1  
        end  
    end  
    return  self:b2d(r)  
end --bit:_not  
  
function    bit:_rshift(a,n)  
    local   op1=self:d2b(a)  
    local   r=self:d2b(0)  
      
    if n < 32 and n > 0 then  
        for i=1,n do  
            for i=31,1,-1 do  
                op1[i+1]=op1[i]  
            end  
            op1[1]=0  
        end  
    r=op1  
    end  
    return  self:b2d(r)  
end --bit:_rshift  
  
function    bit:_lshift(a,n)  
    local   op1=self:d2b(a)  
    local   r=self:d2b(0)  
  
    if n < 32 and n > 0 then  
        local h = 1
        for i = n+1, 32 do
            r[h]=op1[i]
            h=h+1
        end
    end  
    return  self:b2d(r)  
end --bit:_lshift  

--生成字符串哈希码
function BKDRHash(args)
    local seed = 31
    local hash = 0
    for i = 1, string.len(args)  do
        --hash = hash *seed + string.byte(args, i)
        --hash = (*str++) + (hash << 6) + (hash << 16) - hash;
        hash = string.byte(args, i) + bit:_lshift(hash,6) + bit:_lshift(hash,16) - hash;
    end
    local re = bit:_and(hash ,0x7fffffff)
    return re
end]]

--初始化字典表（通过脚本dictionary，然后从新哈希，以保证不同平台哈希码一致）
if g_LResPath ~= nil then
    g_LoadFile(g_LResPath[LResType].cfg .. "/DictionaryInCode")
else
    g_LoadFile("Config/DictionaryInCode")
end

local _Dictionary= {}
local cnt = 0;
function InitDictionary()
    if BKDRHash == nil then return end

    local csv_dir = ConfigMgr["DictionaryInCode"]
    if csv_dir == nil then return end
    for k,v in pairs(csv_dir) do
        cnt = cnt + 1
        _Dictionary[ BKDRHash(v["Chinese"]) ] = v["Foreign"]
    end
end

--翻译
function _T(args)
    if BKDRHash == nil then return args end
    local str = _Dictionary[ BKDRHash(args) ]
    if str == nil then return args end
    return str
end

InitDictionary()