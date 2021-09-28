--[[
	文件名：TabView.lua
	文件描述：分页显示中的页面切换控件
	创建人：libowen
	创建时间：2016.4.25
--]]

local TabView = class("TabView", function(params)
	return display.newLayer()
end)

--[[
-- 参数 params 中的每项为：
    {
        btnInfos:   -- 切换按钮信息，必传参数,其中每项为
        {
            {
                tag:  按钮的标识，默认为该条目在列表中的index
                position: 按钮的位置，默认会自动排列
                titlePosRateY: title图片或文字的Y坐标相对按钮高度的比例，默认为0.4

                -- 如果按钮上显示的是程序字时可以传入这些参数
                text: 按钮上显示的文字
                fontSize: 按钮上显示文字的大小
                outlineColor: 按钮上文字的描边颜色
                outlineSize: 按钮上文字的描边大小

                -- 如果按钮上显示的是图片字时可以传入这些参数
                normalTextImage: 未选中时图片字的文件名
                lightedTextImage: 选中时图片字的文件名

                -- 特殊的自定义设置（有了这些设置后，该按钮会忽略统一配置的背景图片、文字颜色、描边颜色）
                customNormalImage: 正常状态的自定义按钮图片
                customLightedImage: 选中状态的自定义按钮图片
                customNormalTextcolor: 正常状态的自定义标题颜色
                customLightedTextcolor: 选中状态的自定义标题颜色
                curstomNormalOutlineColor: 正常状态的自定义描边颜色
                curstomLightedOutlineColor: 选中状态的自定义描边颜色
            }
            ...
        }
        allowChangeCallback: 是否允许改变选中按钮的回调，函数原型为 allowChangeCallback(btnTag)
        onSelectChange: 当选中按钮改变的回调函数，函数原型为： onSelectChange(selectBtnTag)

        -- ========= 以下为可选参数 ===========
        viewSize:   -- 控件的显示大小, 默认为：cc.size(640, 80)
        isVert:     -- 切换按钮是否垂直排列，默认为false
        space:      -- 切换按钮之间的间距，默认为:14
        btnSize:    -- 切换按钮的大小，默认为：cc.size(116, 53)
        normalImage:    -- 切换按钮未选中时的图片，默认为 "c_17.png"
        lightedImage:   -- 切换按钮选中时的图片，默认为 "c_18.png"

        -- 如果按钮上显示的是程序字时使用这两个参数
        normalTextColor:-- 切换按钮未选中时文字的颜色： 默认为： Enums.Color.eBtnNormal
        lightedTextColor:-- 切换按钮选中时文字的颜色： 默认为：Enums.Color.eBtnSelect

        needLine:       -- 是否需要切换按钮于实际页面页面内容之间的分隔线，默认为 true
        defaultSelectTag:-- 默认选中按钮的 tag， 默认为 btnInfos 中第一个按钮信息的tag
    }
]]
function TabView:ctor(params)
    --  切换按钮信息
    self.mBtnInfos = clone(params.btnInfos)
    -- 控件的显示大小
    self.mViewSize = params.viewSize or cc.size(640, 80)
    -- 切换按钮是否垂直排列
    self.mIsVert = params.isVert or false
    -- 切换按钮之间的间距
    self.mSpace = params.space or 14
    -- 切换按钮的大小
    self.mBtnSize = params.btnSize or cc.size(116, 53)
    -- 切换按钮未选中时的图片
    self.mNormalImage = params.normalImage or "c_152.png"
    -- 切换按钮选中时的图片
    self.mLightedImage = params.lightedImage or "c_151.png"
    -- 切换按钮未选中时文字的颜色
    self.mNormalTextColor = params.normalTextColor or cc.c3b(0xff, 0xff, 0xec)
    -- 切换按钮选中时文字的颜色
    self.mLightedTextColor = params.lightedTextColor or cc.c3b(0xfa, 0xf6, 0xf1)
    -- 是否需要切换按钮于实际页面页面内容之间的分隔线
    self.mNeedLine = params.needLine ~= false

    -- 当前选中按钮的Tag
    self.mSelectTag = params.defaultSelectTag or self.mBtnInfos[1] and self.mBtnInfos[1].tag or 1
    -- 导航按钮列表
    self.mTabBtnList = {}
    -- 页面内容显示的大小
    self.mInnerSize = self.mViewSize
    -- 计算切换按钮的信息
    self:dealBtnInfo()

    -- 是否允许改变选中按钮的回调
    self.allowChangeCallback = params.allowChangeCallback
    -- 当选中按钮改变的回调函数
    self.onSelectChange = params.onSelectChange

    -- 设置自身的大小
    self:setContentSize(self.mViewSize)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setIgnoreAnchorPointForPosition(false)

    --
    self:initUI()
end

-- 计算切换按钮的信息
function TabView:dealBtnInfo()
    -- 计算切换按钮的位置信息
    local innerWidth, innerHeight = 0, 0
    if self.mIsVert then
        innerWidth = self.mViewSize.width
        local tempPosX, tempPosY = self.mViewSize.width - 9 - self.mBtnSize.width / 2, -14
        for index = #self.mBtnInfos, 1, -1 do
            local tempItem = self.mBtnInfos[index]
            if not tempItem.position then
                tempItem.position = cc.p(tempPosX, tempPosY - self.mBtnSize.height / 2)
            else
                tempItem.position = cc.p(tempPosX, tempItem.position.y - self.mViewSize.height)
            end
            innerHeight = math.abs(tempItem.position.y)
            tempPosY = tempItem.position.y - self.mBtnSize.height / 2 - self.mSpace
        end
        innerHeight = math.max(innerHeight, self.mViewSize.height)
        for index, item in pairs(self.mBtnInfos) do
            item.tag = item.tag or index
            item.position = cc.p(item.position.x, item.position.y + innerHeight)
        end
    else
        innerHeight = self.mViewSize.height
        local tempPosX, tempPosY = 14, self.mBtnSize.height / 2 + 9
        for index, item in ipairs(self.mBtnInfos or {}) do
            item.tag = item.tag or index
            if not item.position then
                item.position = cc.p(tempPosX + self.mBtnSize.width / 2, tempPosY)
            else
                item.position.y = tempPosY
            end
            innerWidth = item.position.x + self.mBtnSize.width / 2
            tempPosX = innerWidth + self.mSpace
        end
        innerWidth = math.max(innerWidth, self.mViewSize.width)
    end

    self.mInnerSize = cc.size(innerWidth, innerHeight)
end

-- 创建页面控件
function TabView:initUI()
    -- 详细信息滑动部分
    local scrollView = ccui.ScrollView:create()
    scrollView:setContentSize(self.mViewSize)
    scrollView:setDirection(self.mIsVert and ccui.ScrollViewDir.vertical or ccui.ScrollViewDir.horizontal);
    self:addChild(scrollView)
    scrollView:setInnerContainerSize(self.mInnerSize)
    scrollView:jumpToTop()
    self.mScrollView = scrollView

    -- 创建切换按钮
    for index, item in ipairs(self.mBtnInfos) do
        -- 创建按钮
        local tempBtn = ui.newButton({
            normalImage = self:getBtnBackImg(item),
            size = self.mBtnSize,
            position = item.position,
            text = item.text,
			fontSize = item.fontSize or 24,
            --fontSize = 24,
            textColor = self:getBtnTextColor(item),
            textWidth = self.mIsVert and 30,
            titlePosRateY = item.titlePosRateY or 0.4,
            titleImage = self:getBtnTitleImg(item),
            outlineColor = self:getBtnOutlineColor(item),
            outlineSize = item.outlineSize,
            clickAction = function()
                if not self:activeTabBtnByTag(item.tag) then
                    return
                end

                -- 通知创建者选中按钮发生改变
                if self.onSelectChange then
                    self.onSelectChange(self.mSelectTag)
                end
            end,
        })
        scrollView:addChild(tempBtn, (item.tag == self.mSelectTag) and 2 or 0)
		tempBtn.tag = item.tag
        self.mTabBtnList[item.tag] = tempBtn
    end
    -- 默认调用一次
    if self.onSelectChange then
        self.onSelectChange(self.mSelectTag)
    end

    if self.mNeedLine then
        local tempWidth = self.mIsVert and self.mInnerSize.height or self.mInnerSize.width
        local lineSprite = ui.newScale9Sprite("c_20.png", cc.size(tempWidth, 15))

        scrollView:addChild(lineSprite, 3)
        if self.mIsVert then
            lineSprite:setPosition(self.mViewSize.width - 5, self.mViewSize.height / 2)
            lineSprite:setRotation(90)
        else
            lineSprite:setPosition(tempWidth / 2, 8)
        end
    end
end

-- 获取当前选中按钮的tag
function TabView:getCurrTag()
    return self.mSelectTag
end

-- 获取所有切换按钮
--[[
-- 返回值的形势
    {
        [btnTag] = btnObj,
        ...
    }
]]
function TabView:getTabBtns()
    return self.mTabBtnList
end

-- 根据按钮标识获取切换按钮
function TabView:getTabBtnByTag(btnTag)
    return self.mTabBtnList[btnTag]
end

-- 根据按钮标识激活按钮
function TabView:activeTabBtnByTag(btnTag)
    -- 和原来选中的按钮是同一个 \  调用者不允许切换
    if btnTag == self.mSelectTag or  self.allowChangeCallback and not self.allowChangeCallback(btnTag) then
        -- 不能切换
        return false
    end

    -- 查找该tag对应的按钮信息
    local oldBtnInfo, newBtnInfo = {}, {}
    for _, item in pairs(self.mBtnInfos) do
        if item.tag == self.mSelectTag then
            oldBtnInfo = item
        elseif item.tag == btnTag then
            newBtnInfo = item
        end
    end

    local oldSelectBtn = self.mTabBtnList[self.mSelectTag]
    local newSelectBtn = self.mTabBtnList[btnTag]

    self.mSelectTag = btnTag
    if oldSelectBtn then
        local parentNode = oldSelectBtn:getParent()
        -- 改变按钮的状态
        local titleImg = self:getBtnTitleImg(oldBtnInfo)
        local normalImg = oldBtnInfo.customNormalImage or self.mNormalImage
        oldSelectBtn:loadTextures(normalImg, normalImg)
        oldSelectBtn:setTitleColor(oldBtnInfo.customNormalTextcolor or self.mNormalTextColor)
        oldSelectBtn.mTitleLabel:enableOutline(self:getBtnOutlineColor(oldBtnInfo), oldBtnInfo.outlineSize or 2)
        if string.isImageFile(titleImg) then
            oldSelectBtn:setTitleImage(titleImg)
        end
        parentNode:reorderChild(oldSelectBtn, 0)
    end

    local titleImg = self:getBtnTitleImg(newBtnInfo)
    local normalImg = newBtnInfo.customLightedImage or self.mLightedImage
    newSelectBtn:loadTextures(normalImg, normalImg)
    newSelectBtn:setTitleColor(newBtnInfo.customLightedTextcolor or self.mLightedTextColor)
    newSelectBtn.mTitleLabel:enableOutline(self:getBtnOutlineColor(newBtnInfo), newBtnInfo.outlineSize or 2)
    if string.isImageFile(titleImg) then
        newSelectBtn:setTitleImage(titleImg)
    end
    local parentNode = newSelectBtn:getParent()
    parentNode:reorderChild(newSelectBtn, 2)

    return true
end

----------------------------------------------------------------------------------------------------

-- 获取按钮背景图片
function TabView:getBtnBackImg(item)
    local buttonImage = (item.tag == self.mSelectTag) and self.mLightedImage or self.mNormalImage
    if item.customNormalImage and item.customLightedImage then
        buttonImage = (item.tag == self.mSelectTag) and item.customLightedImage or item.customNormalImage
    end
    return buttonImage
end

-- 获取按钮标题图片
function TabView:getBtnTitleImg(item)
    local titleImg
    if item.tag == self.mSelectTag then
        titleImg = item.lightedTextImage or item.normalTextImage or item.titleImage
    else
        titleImg = item.normalTextImage or item.lightedTextImage or item.titleImage
    end
    return titleImg
end

-- 获取按钮文字颜色
function TabView:getBtnTextColor(item)
    local titleTextColor = nil
    if (item.tag == self.mSelectTag) then
        titleTextColor = item.customLightedTextcolor or self.mLightedTextColor
    else
        titleTextColor = item.customNormalTextcolor or self.mNormalTextColor
    end
    return titleTextColor
end

-- 获取按钮描边颜色
function TabView:getBtnOutlineColor(item)
    local titleOutlineColor = nil
    if item.outlineColor then
        titleOutlineColor = item.outlineColor
    else
        if (item.tag == self.mSelectTag) then
            titleOutlineColor = item.curstomLightedOutlineColor or cc.c3b(0x8d, 0x4b, 0x3b)
        else
            titleOutlineColor = item.curstomNormalOutlineColor or cc.c3b(0x87, 0x56, 0x49)
        end
    end
    return titleOutlineColor
end

return TabView
