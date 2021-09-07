-- ----------------------------
-- 上浮提示元素
-- hosr
-- 规则说明:
-- 1.界面上最多显示6条
-- 2.每条信息的活动是1.7s持续显示时间，0.3s渐隐消失(没有缓动往上飘)
-- 3.新的直接把旧的往上顶，最后一条直接干掉，轮回到第一条用
-- 4.每条最大宽度 480， 最小宽度240
-- ----------------------------
NoticeFloatItem = NoticeFloatItem or BaseClass()

function NoticeFloatItem:__init(transform)
    self.id = 0

    self.transform = transform
    self.gameObject = transform.gameObject
    self.gameObject:SetActive(false)
    self.image = self.gameObject:GetComponent(Image)
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.label = transform:Find("Text"):GetComponent(Text)
    self.label_rect = self.label.gameObject:GetComponent(RectTransform)
    self.contentTrans = self.label.gameObject.transform
    self.gameObject:GetComponent(CanvasGroup).blocksRaycasts = false
    self.width = 0
    self.height = 30

    self.showing = false
    self.timeId = 0
    self.tweenDesc = nil
    self.alphaDesc = nil
    self.target = 0
    self.defaultColor = Color(1,1,1,1)

    self.imgTab = {}
    self.faceTab = {}
    self.lineSpace = 20

    self.imgTempTab = {}
    self.faceTempTab = {}

    self.useCount = 0

    -- 道具和宠物要显示头像在前面
    self.extX = 0
    self.extY = 0

    self.wholeOffsetChar = 0
    self.staticFontSize = 19

    self.loaders = {}
    self.headLoaderList = {}
end

function NoticeFloatItem:__delete()
    self:ReleaseIconLoader()
      if self.headLoaderList ~= nil then
        for k,v in pairs(self.headLoaderList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.headLoaderList = nil
    end
    self.loaders = nil
end

function NoticeFloatItem:ReleaseIconLoader()
    for k,v in pairs(self.loaders) do
        v:DeleteMe()
        v = nil
    end
    self.loaders = nil
    self.loaders = {}
end

function NoticeFloatItem:Reset()
    self:ReleaseIconLoader()
    self.showing = false
    if self.timeId ~= 0 then
        LuaTimer.Delete(self.timeId)
    end
    self.target = 100
    self.defaultHeight = 100
    -- self.target = 60
    self.transform.localPosition = Vector3(0, self.target, 0)
    self.image.color = self.defaultColor
    self.label.text = ""
    self.extX = 0
    self.extY = 0
    self.wholeOffsetChar = 0

    for i,v in ipairs(self.imgTempTab) do
        v:SetActive(false)
        table.insert(self.imgTab, v)
    end
    self.imgTempTab = {}

    for i,v in ipairs(self.faceTempTab) do
        v:DeleteMe()
        v = nil
    end
    self.faceTempTab = {}

    self.useCount = self.useCount + 1
    self.useCount = math.min(self.useCount, 2)
    self.msgData = nil
end

function NoticeFloatItem:SetData(floatData)
    self:Reset()

    self.showing = true
    -- self.msgData = floatData
    local msg = floatData.showString
    msg = string.gsub(msg, "<color='(.-)'>(.-)</color>", "{string_2,%1,%2}")
    -- msg = string.gsub(msg, "%%", "％")
    -- msg = string.gsub(msg, "%-", "－")
    -- msg = string.gsub(msg, "%+", "＋")
    -- msg = string.gsub(msg, "%*", "×")
    msg = string.gsub(msg, " ", "　")
    self.msgData = MessageParser.OneMethod(msg)
    self.label.text = self.msgData.pureString

    self:Layout()

    -- self:ShowElements(floatData.elements)

    self.gameObject:SetActive(true)
    self:BeginAlive()
end

-- 处理宽高
function NoticeFloatItem:Layout()
    local preferredWidth = self.label.preferredWidth
    self.height = 30
    self.label_rect.sizeDelta = Vector2(preferredWidth, self.height)

    -- 加上上下左右空隙作为最外层容器宽高
    self.width = math.max(preferredWidth, 240)
    self.txtMaxWidth = self.width
    self.width = self.width + 40
    self.height = self.height + 10
    self.rect.sizeDelta = Vector2(self.width, self.height)

    self.label_rect.anchoredPosition = Vector2((self.width - math.ceil(preferredWidth)) / 2, -5)

    self:Generator()
end

function NoticeFloatItem:ExtLayout()
    if self.extY ~= 0 then
        self.height = self.extY + 6
    end
    local preferredWidth = self.label.preferredWidth
    self.width = math.max(preferredWidth, 240)
    self.txtMaxWidth = self.width
    self.width = self.width + self.extX * 2 + 40
    self.rect.sizeDelta = Vector2(self.width, self.height)
    -- self.label_rect.anchoredPosition = Vector2(self.extX, -2)
    self.label_rect.anchoredPosition = Vector2((self.width - math.ceil(preferredWidth)) / 2 + self.extX, -13)
end

-- 开始生存周期
function NoticeFloatItem:BeginAlive()
    self.timeId = LuaTimer.Add(1800, function() self:Dying() end)
end

-- 消失
function NoticeFloatItem:Dying()
    self.alphaDesc = Tween.Instance:Alpha(self.rect, 0, 0.3, function() self:End() end)
end

-- 生存周期完成
function NoticeFloatItem:End()
    self.showing = false
    self.gameObject:SetActive(false)

    for i,v in ipairs(self.faceTab) do
        v:DeleteMe()
        v = nil
    end
    self.faceTab = {}
end

-- 往上移动自己的高度，不需要间隔
function NoticeFloatItem:MoveUp(h)
    self.target = h + self.defaultHeight
    self.tweenDesc = Tween.Instance:MoveLocalY(self.gameObject, self.target, 0.1)
end


-- ---------------------------------
-- 处理元素
-- ---------------------------------
function NoticeFloatItem:ShowElements(elements)
    local needReLayout = false
    for i,msg in ipairs(elements) do
        -- local count = math.floor(msg.startX / self.txtMaxWidth)
        -- 换行之后处在当前行的开始位置
        -- 放在具体地方做是因为每个地方的行宽不一样
        -- local currentLineStartX = msg.startX - self.txtMaxWidth * count

        if msg.assetId ~= 0 then
            local img = self:GetImage()
            if GlobalEumn.CostTypeIconName[msg.assetId] == nil then
                local id = img:GetInstanceID()
                local imgLoader = self.loaders[id]
                if imgLoader == nil then
                    imgLoader = SingleIconLoader.New(img)
                    self.loaders[id] = imgLoader
                end
                imgLoader:SetSprite(SingleIconType.Item, DataItem.data_get[tonumber(msg.assetId)].icon)
            else
                img:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[msg.assetId])
            end
            local rect = img:GetComponent(RectTransform)
            rect.sizeDelta = Vector2(28, 28)
            -- rect.anchoredPosition = Vector2(currentLineStartX + msg.offsetX, msg.offsetY - count * self.lineSpace)
            rect.anchoredPosition = Vector2(self.posxDic[i], self.posyDic[i] - 5)
            table.insert(self.imgTempTab, img)
            img:SetActive(true)
        elseif msg.itemId ~= 0 then
            local img = self:GetImage()
            local id = img:GetInstanceID()
            local imgLoader = self.loaders[id]
            if imgLoader == nil then
                imgLoader = SingleIconLoader.New(img)
                self.loaders[id] = imgLoader
            end
            imgLoader:SetSprite(SingleIconType.Item, msg.iconId)

            local rect = img:GetComponent(RectTransform)
            rect.sizeDelta = Vector2(48, 48)
            rect.anchoredPosition = Vector2(-48, 15)
            table.insert(self.imgTempTab, img)
            img:SetActive(true)
            self.extX = 24
            self.extY = 48
            needReLayout = true
        elseif msg.petId ~= 0 then
            local img = self:GetImage()
            local loaderId = img:GetComponent(Image).gameObject:GetInstanceID()
            if self.headLoaderList[loaderId] == nil then
                self.headLoaderList[loaderId] = SingleIconLoader.New(img:GetComponent(Image):GetComponent(Image).gameObject)
            end
            self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,msg.iconId)
            -- img:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(msg.iconId), tostring(msg.iconId))
            local rect = img:GetComponent(RectTransform)
            rect.sizeDelta = Vector2(48, 48)
            rect.anchoredPosition = Vector2(-48, 15)
            table.insert(self.imgTempTab, img)
            img:SetActive(true)
            self.extX = 24
            self.extY = 48
            needReLayout = true
        elseif msg.faceId ~= 0 then
            local face = self:GetFaceItem()
            -- face:Show(msg.faceId, Vector2(currentLineStartX + msg.offsetX, msg.offsetY - count * self.lineSpace))
            face:Show(msg.faceId, Vector2(self.posxDic[i], self.posyDic[i]))
            table.insert(self.faceTempTab, face)
        end
    end
    if needReLayout then
        self:ExtLayout()
    end
end

function NoticeFloatItem:GetImage()
    local rect = nil
    local obj = nil
    if #self.imgTab > 0 then
        obj = self.imgTab[1]
        table.remove(self.imgTab, 1)
    else
        obj = GameObject()
        obj:AddComponent(Image)
        obj.name = "Image"
        local trans = obj.transform
        trans:SetParent(self.contentTrans)
        trans.localPosition = Vector3.zero
        trans.localScale = Vector3.one
        rect = obj:GetComponent(RectTransform)
        rect.anchorMin = Vector2(0, 1)
        rect.anchorMax = Vector2(0, 1)
        rect.pivot = Vector2(0, 1)
    end
    return obj
end

function NoticeFloatItem:GetFaceItem()
    local face = nil
    if #self.faceTab > 0 then
        face = self.faceTab[1]
        table.remove(self.faceTab, 1)
    else
        face = FaceItem.New(self.contentTrans)
    end
    return face
end

function NoticeFloatItem:Generator()
    local generator = self.label.cachedTextGeneratorForLayout
    local isDynamic = self.label.font.dynamic;

    -- print("####################### begin ##########################")
    -- print("text=\n" .. self.label.text)
    -- print("lineCount=" .. generator.lineCount)
    local lineDic = {}
    self.posxDic = {}
    self.posyDic = {}
    for i = 1, generator.lineCount do
        local lineInfo = generator.lines[i - 1]
        -- UILineInfo
        -- print("UILineInfo " .. i)
        -- print("height=" .. lineInfo.height)
        -- print("line=" .. i .. ",startCharIdx=" .. lineInfo.startCharIdx + 1)
        table.insert(lineDic, lineInfo.startCharIdx + 1)
    end

    local getLine = function(idx)
        for line,startIdx in ipairs(lineDic) do
            if idx < startIdx then
                return line - 1
            end
        end
        return #lineDic
    end

    local getWidth = function(element)
        local gw = 0
        for a = element.tagIndex, element.tagEndIndex do
            gw = gw + generator.characters[a - 1].charWidth
        end
        return gw
    end

    -- print("characterCount=" .. generator.characterCount)
    -- for i = 1, generator.characterCount do
    --     local charInfo = generator.characters[i - 1]
    --     print("charWidth=" .. charInfo.charWidth)
    --     print("cursorPos=[" .. charInfo.cursorPos.x .. "," .. charInfo.cursorPos.y .. "]")
    -- end

    -- local needMore = {}
    for i,element in ipairs(self.msgData.elements) do
        local idx = element.tagIndex + element.offsetChar + self.wholeOffsetChar
        local charInfo = generator.characters[idx - 1]
        local line = getLine(idx)
        local height = -self.lineSpace * (line - 1) + element.offsetY
        local width = charInfo.cursorPos.x + element.offsetX

        if not isDynamic then
            -- 静态字体取到的值是以静态字体本身设置的大小(19号)为标准的，这里如果显示的字体不是设置大小的话，需要一个比例来矫正
            width = width * (self.label.fontSize / self.staticFontSize)
        end

        element.width = getWidth(element)
        if isDynamic == true then
            width = MessageParser.ScaleVal(width)
        end
        element.width = MessageParser.ScaleVal(element.width)
        table.insert(self.posxDic, width)
        table.insert(self.posyDic, height)

    --     if element.tag == "item_1" or element.tag == "pet_1" or element.tag == "role_1" or element.tag == "unit_2" or element.tag == "honor_1" or element.tag == "panel_1" or element.tag == "panel_2" then
    --         local firstWidth = 0
    --         local secondWidth = 0
    --         for j = idx, element.tagEndIndex do
    --             if secondWidth == 0 then
    --                 if width + firstWidth + generator.characters[j - 1].charWidth >= self.txtMaxWidth then
    --                     secondWidth = generator.characters[j - 1].charWidth
    --                 else
    --                     firstWidth = firstWidth + generator.characters[j - 1].charWidth
    --                 end
    --             else
    --                 secondWidth = secondWidth + generator.characters[j - 1].charWidth
    --             end
    --         end
    --         element.width = firstWidth

    --         if secondWidth > 0 then
    --             local addOne = BaseUtils.copytab(element)
    --             addOne.width = secondWidth
    --             needMore[i + 1] = addOne
    --             table.insert(self.posxDic, 0)
    --             table.insert(self.posyDic, height - self.lineSpace)
    --         end
    --     end
    end
    -- -- print("####################### end  ##########################")

    -- for idx,v in pairs(needMore) do
    --     table.insert(self.msgData.elements, idx, v)
    -- end

    self:ShowElements(self.msgData.elements)
    self.label.text = self.msgData.showString
end
