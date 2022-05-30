-- Created by IntelliJ IDEA.
-- User: lfl 1204825992@qq.com
-- Date: 2014/12/18
-- Time: 10:01
-- [[文件功能：敏感词排查
--  将所有敏感词库按模块聚合构建成一个词树
-- (所谓聚合，就是将相同字开头的部分进行聚合，以减少对词的查询范围，相当于建立敏感词索引，
-- 如：他奶奶的、他妈的、他娘的，这三个词，聚合构建成词树时，“他”字就是这三个词的索引，
-- 同时每个词的结尾都有一个结束标志和该词的一些描述，如敏感级别等），然后从头到尾扫描一遍目标文本，
-- 当遇到以敏感词树中的索引的字时，查看后面的文本是否构成敏感词（如果这里有以这个敏感词
-- 开头的更长的敏感词时，以更长的为匹配结果，并判断该词在文本中前后是否有分隔符来区别其匹配方式)，
-- 如果是则记录，一遍扫描完之后所有敏感词即被扫描出来了
-- ]]

--TreeNode类节点-------------------------------------
TreeNode = TreeNode or BaseClass()
function TreeNode:__init()
    self.data    = {}   -- 保存子节点的数据
    self._isLeaf = nil  -- 是否叶子节点
    --是否是敏感词的词尾字，敏感词树的叶子节点必然是词尾字，父节点不一定是
    self.isEnd = false  -- 是否敏感词结尾的节点
    self.parent = nil   -- 父节点
    self.value = nil    -- 当前节点的敏感词
end

--根据敏感词获取节点
function TreeNode:getChild(name)
    return self.data[name]
end

--根据敏感词加上节点
function TreeNode:addChild(char)
    local node = TreeNode.New()
    self.data[char] = node
    node.value = char
    node.parent = self
    return node
end

--获取当前节点以及之上的连串的敏感词字符串
function TreeNode:getFullWord()
    local rt = self.value
    local node = self.parent
    while node do
        rt = string.format("%s%s", node.value, rt)
        node = node.parent
    end
    return rt
end

--是否是叶子节点
function TreeNode:isLeaf()
    local index = 0 --该节点子节点的数量
    for k, v in pairs(self.data) do
        index = index + 1
    end
    --如果没有子节点就是叶子节点
    self._isLeaf = (index == 0)
    return self._isLeaf
end

--敏感词屏蔽的功能--------------------------
WordCensor = WordCensor or BaseClass()
function WordCensor:__init()
    --敏感词的表，一般读取配置
    self.word_config = {"你妹啊","你大爷啊","我擦","你sb啊","傻逼","顶你的肺啊","2b青年", "两百五"}
    --敏感词树根节点
    self.treeRoot = self:createRootNode(self.word_config)
    WordCensor.Instance = self
end

function WordCensor:getInstance()
    if not WordCensor.Instance then
        WordCensor.New()
    end
    return WordCensor.Instance
end

-- 拆分出单个字符
function WordCensor:stringToChars(str)
    -- 主要用了Unicode(UTF-8)编码的原理分隔字符串
    -- 简单来说就是每个字符的第一位定义了该字符占据了多少字节
    -- UTF-8的编码：它是一种变长的编码方式
    -- 对于单字节的符号，字节的第一位设为0，后面7位为这个符号的unicode码。因此对于英语字母，UTF-8编码和ASCII码是相同的。
    -- 对于n字节的符号（n>1），第一个字节的前n位都设为1，第n+1位设为0，后面字节的前两位一律设为10。
    -- 剩下的没有提及的二进制位，全部为这个符号的unicode码。
    local list = {}
    local len = string.len(str)
    local i = 1
    while i <= len do
        local c = string.byte(str, i)
        local shift = 1
        if c > 0 and c <= 127 then
            shift = 1
        elseif (c >= 192 and c <= 223) then
            shift = 2
        elseif (c >= 224 and c <= 239) then
            shift = 3
        elseif (c >= 240 and c <= 247) then
            shift = 4
        end
        local char = string.sub(str, i, i+shift-1)
        i = i + shift
        table.insert(list, char)
    end
    return list, len
end

--创建根节点
function WordCensor:createRootNode(words)
    --这是一个预处理步骤，生成敏感词索引树，功耗大于查找时使用的方法，但只在程序开始时调用一次。
    --根节点
    local treeRoot = TreeNode.New()
    treeRoot.value = ""
    --敏感词长度
    local words_len = table.getn(words)
    --开始构建树
    for i = 1, words_len do
       local temp_word = words[i]  --取词
       --转化过后的词，在lua中中文和其他的英文等字符占的字节数不同
       local word = self:stringToChars(temp_word)
       local len = table.getn(word) --取词长度
       local currentBranch = treeRoot
       for c = 1, len do --对每个词中字符进行遍历
           local char = word[c]
           local tmp = currentBranch:getChild(char)
           if tmp then
               currentBranch = tmp
           else
               currentBranch = currentBranch:addChild(char)
           end
       end
       currentBranch.isEnd = true
    end
    return treeRoot
end

--获取树根节点
function WordCensor:getRootNode()
    return self.treeRoot
end

--[[
--  检查字符串并且替换敏感词
-- ]]
function WordCensor:replaceWordCensor(wordString)
    local char           -- 每个字符
    local childTree      -- 孩子节点
    local curEndWordTree
    local dirtyWord
    local curTree = self:getRootNode()
    local dirtyWords = wordString --判断字符串
    local temp_words = self:stringToChars(wordString) --转化之后的
    local c = 1            --循环索引
    --需要回溯一下，因为这个回合是在匹配的下一个执行的，不然就会有一个轮空
    local endIndex = 0     --词尾索引
    local middleIndex = 0  --敏感词非词尾索引
    while c <= table.getn(temp_words) do
        char = temp_words[c]  --每个字符
        childTree = curTree:getChild(char)  --孩子节点
        if childTree then --在树中遍历
            if childTree.isEnd then
                curEndWordTree = childTree
                endIndex = c
            end
            middleIndex = c
            curTree = childTree
            c = c + 1
        else  --跳出树的遍历
            if curEndWordTree then--如果之前有遍历到词尾，则替换该词尾所在的敏感词，然后设置循环索引为该词尾索引
                dirtyWord = curEndWordTree:getFullWord() --取得敏感词全部
                local temp_tab = self:stringToChars(dirtyWord)
                dirtyWords = string.gsub(dirtyWords, dirtyWord, self:getReplaceWord(table.getn(temp_tab)))
                c = endIndex --回溯
            elseif curTree ~= self:getRootNode() then --如果之前有遍历到敏感词非词尾，匹配部分未完全匹配，则设置循环索引为敏感词非词尾索引
                c = middleIndex --回溯
            end
            --替换掉一部分，下面的要从树根再开始判断
            curTree = self:getRootNode()
            curEndWordTree = nil
            c = c + 1
        end
    end
    --循环结束时，如果最后一个字符满足敏感词词尾条件，此时满足条件，但未执行替换，在这里补加
    if curEndWordTree then
        dirtyWord = curEndWordTree.getFullWord()
        local temp_tab = self:stringToChars(dirtyWord)
        dirtyWords = string.gsub(dirtyWords, dirtyWord, self:getReplaceWord(table.getn(temp_tab)))
    end
    return dirtyWords
end


function WordCensor:getReplaceWord(len)
    local replaceWord = ""
    for i = 1, len do
        replaceWord = string.format("%s%s", replaceWord, "*")
    end
    return replaceWord
end


--替换聊天之中的标签
function WordCensor:relpaceChatTag(text)
    local index = 0
    for beginindex, endindex in function()
        return string.find(text, "[<>]", index)
    end
    do
        local label = string.sub(text, beginindex, endindex)
        text = string.gsub(text, label, "")
        index = endindex + 1
    end
    return text
end

--替换资产标签 替换内容 <assets=资产代号/> 如: <assets=1/>
function WordCensor:relapceAssetsTag(text)
    local index = 0
    local rep_array = Array.New()
    for beginindex, endindex in function()
        return string.find(text, "(%<assets=)(.-)(%/)(%>)")
    end
    do
        local match_str = string.sub(text, beginindex, endindex)
        local assets_name = string.sub(match_str, 9, -3)
        local assets_url
        local config = Config.ItemData.data_get_data(tonumber(assets_name))
       
        if config then
            assets_url = PathTool.getItemRes(config.icon, true)
        end
        if not cc.FileUtils:getInstance():isFileExist(assets_url) then
            return text
        end
       
        text = string.gsub(text, match_str, "STR___", 1)
        rep_array:PushBack(string.format("<img src='%s' scale=0.3 />", assets_url))
        index = endindex+1
    end
    while rep_array:GetSize() > 0 do
        text = string.gsub(text, "STR___", rep_array:PopFront(), 1)
    end
    
    return text
end

--替换资产标签 替换内容 <icon=图标名字/> 如: <icon=smile/>
function WordCensor:relapceChatIconTag(text)
    local index = 0
    local rep_array = Array.New()
    for beginindex, endindex in function()
        return string.find(text, "(%<icon=)(.-)(%/)(%>)", index)
    end
    do
        local match_str = string.sub(text, beginindex, endindex)
        local assets_name = string.sub(match_str, 9, -3)
        local assets_url = PathTool.getChatRes(assets_name)
        if not cc.FileUtils:getInstance():isFileExist(assets_url) then
            return text
        end
        text = string.gsub(text, match_str, "STR___")
        rep_array:PushBack(string.format("<img src='%s' scale=0.25 />", assets_url))
        index = endindex + 1
    end
    while rep_array:GetSize() > 0 do
        text = string.gsub(text, "STR___", rep_array:PopFront(), 1)
    end
    return text
end

--替换表情标记 替换内容 #数字 如: #1
function WordCensor:relapceFaceIconTag(text)
    local max_val = Config.FaceData.data_biaoqing_length
    local index = 0
    local rep_array = Array.New()
    for beginindex, endindex in function()
        return string.find(text, "(%#)%d+", index)
    end
    do
        local match_str = string.sub(text, beginindex, endindex)
        if beginindex > 1 and string.sub(text, beginindex-1, beginindex-1) == "=" then

        else
            local num_str = string.sub(match_str, 2)
            local num_len = string.len(num_str)
            local bool = true
            local new_str = ""
            while bool do
                if tonumber(num_str) > max_val then
                    num_str = string.sub(num_str, 1, num_len-1)
                    if num_len-1 == string.len(num_str) then
                        bool = nil
                    end
                else
                    text = string.gsub(text, "#"..num_str, "STR___", 1)
                    if Config.FaceData.data_biaoqing[tonumber(num_str)] then
                        rep_array:PushBack(string.format("<img src='%s' />", Config.FaceData.data_biaoqing[tonumber(num_str)].name))
                    end
                    bool = nil
                end
            end
        end
        index = endindex + 1
    end
    local face_num = rep_array:GetSize() --表情个数
    while rep_array:GetSize() > 0 do
        text = string.gsub(text, "STR___", rep_array:PopFront(), 1)
    end
    return {face_num,text}
end