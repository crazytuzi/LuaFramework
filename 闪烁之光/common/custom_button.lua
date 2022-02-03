--[[
  自定义按钮类,实现文字贴图效果
]]

CustomButton = CustomButton or BaseClass()

--[[创建按钮
-- @param normal_res 常态下的按钮图片路径(必填)
-- @param press_res  点击下的按钮图片路径(必填)
 - @param disable_res 不可点击下的按钮图片路径(选填)
-- ]]
function CustomButton:__init(parent, normal_res, press_res, disable_res, load_type,font_type)
    self.load_type = load_type or LOADTEXT_TYPE_PLIST
    self.parent_wnd = parent
    self.normal_res = normal_res
    self.press_res = press_res
    self.disable_res = disable_res
    self.is_other_sound = false -- 点击时是否播其他声音
    self.btn_scale = 1
    self.font_type = font_type or DEFAULT_FONT
    self:initView()
    self:registerEvent()
end

function CustomButton:initView()
    self.layout = ccui.Widget:create()
    self.layout:setCascadeOpacityEnabled(true)
    self.layout:setAnchorPoint(cc.p(0.5, 0.5))
    if self.parent_wnd ~= nil then
        self.parent_wnd:addChild(self.layout)
    end
    self.btn = ccui.Button:create()
    self.btn:setTouchEnabled(true)
    self.layout:addChild(self.btn)
    --设置按钮的数据
    self:setBtnStateImg(self.normal_res, self.press_res or self.normal_res, self.disable_res or "")
end

--设置按钮的三态
function CustomButton:setBtnStateImg(normal_res, press_res, disable_res)
    if normal_res and press_res then
        self.normal_res = normal_res
        self.press_res = press_res
        self.disable_res = disable_res
        self.btn:loadTextures(self.normal_res, self.press_res or self.normal_res, self.disable_res or "", self.load_type)
        local size = self.btn:getContentSize()
        self.btn:setPosition(cc.p(size.width/2, size.height/2))
        self:setSize(size)
    end
end

function CustomButton:loadTextures(normal_res, press_res, disable_res)
   if self.btn and normal_res then
      local press_res = press_res
      local disable_res = disable_res
      self.btn:loadTextures(normal_res, press_res or normal_res, disable_res or "", self.load_type)
   end
end


--设置文本的按钮文字
function CustomButton:setBtnLabel(label,font)
    if self.btn_image_label and self.btn_image_label:isVisible() then
        self.btn_image_label:setVisible(false)
    end

    if self.rich_label and self.rich_label:isVisible() then
        self.rich_label:setVisible(false)
    end

   if self.btn_label == nil then
       self.font_size = self.font_size or 20
       self.btn_label = createLabel(self.font_size,nil,nil,self:getSize().width/2, self:getSize().height/2+1,
          "",self.layout,nil, cc.p(0.5, 0.5),font)
          self.btn_label:setLocalZOrder(10)
       if self.font_color4 then
           self.btn_label:setTextColor(self.font_color4)
       elseif self.font_color then
           self.btn_label:setColor(self.font_color)
       end
   else
       if self.btn_label and not tolua.isnull(self.btn_label) and self.btn_label:isVisible() == false then
           self.btn_label:setVisible(true)
       end
   end
   self.btn_label:setString(label)
end
function CustomButton:setBright(bool)
    self.btn:setBright(bool)
end
--设置文本的按钮图片文字
function CustomButton:setImageLabel(label_res,scale, load_type)
    load_type = load_type or LOADTEXT_TYPE
    local scale = scale or 1
    if self.btn_label and self.btn_label:isVisible() then
        self.btn_label:setVisible(false)
    end
    if self.rich_label then
        self.rich_label:setVisible(false)
    end
    if self.btn_image_label == nil then
        self.btn_image_label = ccui.ImageView:create()
        self.btn_image_label:setPosition(self:getSize().width/2, self:getSize().height/2)
        self.btn_image_label:setScale(scale)
        self.layout:addChild(self.btn_image_label)
    else
        if self.btn_image_label:isVisible() == false then
            self.btn_image_label:setVisible(true)
        end
    end
    self.btn_image_label:loadTexture(label_res, load_type)
end

-- 富文本文字
function CustomButton:setRichText(text,font_size,color,line_space,ap)
  if self.btn_label then
    self.btn_label:setVisible(false)
  end
  if self.btn_image_label then
      self.btn_image_label:setVisible(false)
  end
    
  if not self.rich_label then
    local color = color or 1
    local ap = ap or cc.p(0, 1)
    self.rich_label = createRichLabel(font_size, color,ap, cc.p(0,0), 5, 0,line_space or self:getSize().width )
    self.layout:addChild(self.rich_label)
  end
  self.rich_label:setVisible(true)
  self.rich_label:setString(text)
  self.rich_label:setPosition((self:getSize().width-self.rich_label:getContentSize().width)/2, self:getSize().height/2+self.rich_label:getContentSize().height/2+1 )
end

--设置按钮文本的颜色
function CustomButton:setLabelColor(r, g, b)
    self.font_color = cc.c3b(r, g, b)
    if self.btn_label then
        self.btn_label:setColor(self.font_color)
    end
end

--设置按钮文字的颜色
function CustomButton:setBtnLableColor(color)
    self.font_color4 = color
    if self.btn_label then
        self.btn_label:setTextColor(color)
    end
end

--设置按钮文本的字号(鉴于控件比较坑爹，还是建议在设置文本之前设置字号)
function CustomButton:setLabelSize(size)
    if self.font_size == nil or self.font_size ~= size then
        if self.btn_label then
            self.btn_label:setSystemFontSize(size)
        end
        self.font_size = size
    end
end

--设置按钮文字的位置
function CustomButton:setLabelPosition(x, y)
   if self.btn_image_label and self.btn_image_label:isVisible() then
       self.btn_image_label:setPosition(cc.p(x, y))
   end
   if self.btn_label and self.btn_label:isVisible() then
       self.btn_label:setPosition(cc.p(x, y))
   end
end
function CustomButton:setRichLabelPosition(x,y)
    if self.rich_label and not tolua.isnull(self.rich_label) then
        self.rich_label:setPosition(cc.p(x, y))
    end
end
function CustomButton:setRotation( value )
  self.btn:setRotation(value)
end

function CustomButton:setZOrder(value)
  self.layout:setZOrder(value)
end

--设置滤镜
function CustomButton:enableOutline(color, size)
    if self.btn_label then
        self.btn_label:enableOutline(color, size)
    end
end

--设置按钮文字的偏移位置
function CustomButton:setOffsetPos(offset_x, offset_y)
    self:setLabelPosition(self:getSize().width/2+offset_x, self:getSize().height/2+offset_y)
end

function CustomButton:getSize()
    return self.layout:getContentSize()
end

function CustomButton:getContentSize(  )
  return self.layout:getContentSize()
end

function CustomButton:addTouchEventListener(call_back,isRun)
    self.btn:addTouchEventListener(function(sender, event_type)
        if self.is_open and not isRun == true then
            customClickAction(self.layout, event_type, self.btn_scale)
        end
        if call_back ~= nil then
            call_back(sender, event_type)
        end
        if event_type == ccui.TouchEventType.began then

        elseif event_type == ccui.TouchEventType.ended  then
            if self.is_other_sound == false then
                playButtonSound2()
            end
        elseif event_type == ccui.TouchEventType.canceled then
        end
    end)
end

function CustomButton:setSize(size)
    if size.width >= self:getSize().width and size.height >= self:getSize().height then
       self.btn:setScale9Enabled(true)
    end
    self.btn:setContentSize(size)
    self.layout:setContentSize(size)
    if self.btn_image_label then
        self.btn_image_label:setPosition(cc.p(size.width/2, size.height/2))
    end
    if self.btn_label then
        self.btn_label:setPosition(cc.p(size.width/2, size.height/2))
    end
    self:getButton():setPosition(cc.p(self:getSize().width/2, self:getSize().height/2))
end
--九宫
function CustomButton:setCapInsets(rect)
    self.btn:setCapInsets(rect)
end

function CustomButton:playSound(is_other)
    is_other = is_other or false
    self.is_other_sound = is_other
end
function CustomButton:showRedPoint(bool,x,y,num)
    if not self.red_point then
        self.red_point = createSprite(PathTool.getResFrame("mainui","mainui_1009"),0,0,self.layout,cc.p(1,1))
        self.red_point:setVisible(false)
    end
    if num~=nil and num>0 then
      if not self.red_num then
        self.red_num = createLabel(20,1,nil,self.red_point:getContentSize().width/2-1,self.red_point:getContentSize().height/2+2,num,self.red_point,1,cc.p(0.5,0.5))
      end
      self.red_num:setVisible(true)
      self.red_num:setString(num)
    else
      if self.red_num then
        self.red_num:setVisible(false)
      end
    end
    local x = x or self:getSize().width
    local y = y or  self:getSize().height
    self.red_point:setPosition(x,y)
    self.red_point:setVisible(bool)
end

function CustomButton:setBtnSize(size)
  if size then
     self.btn:setContentSize(size)
  end
end

function CustomButton:setAnchorPoint(x, y)
    self.layout:setAnchorPoint(cc.p(x, y))
end

function CustomButton:setName(name)
    self.btn:setName(name)
end

function CustomButton:getButton()
    return self.btn
end
function CustomButton:setBtnPosition(pos)
    local size = self.btn:getContentSize()
    pos = pos or cc.p(size.width/2,size.height/2)
    self.btn:setPosition(pos)
end
function CustomButton:getLabel()
    return self.btn_label
end

function CustomButton:getImageLabel()
    return self.btn_image_label
end

function CustomButton:getRoot()
    return self.layout
end

function CustomButton:setCascade(bool)
    self.layout:setCascadeOpacityEnabled(bool)
    if bool == true then
        self.layout:setOpacity(140)
    else
        self.layout:setOpacity(255)
    end
end
function CustomButton:setScale(scale)
    if self.btn_scale ~= scale then
        self.btn_scale = scale
        self:getRoot():setScale(scale)
    end
end

function CustomButton:removeFromParent()
    if self.layout then
       if self.layout:getParent() then
           self.layout:removeFromParent()
       end
    end
end

function CustomButton:setVisible(bool)
    self.layout:setVisible(bool)
end

function CustomButton:isVisible( ... )
    return self.layout:isVisible()
end
function CustomButton:setTouchEnabled(bool)
    self.btn:setTouchEnabled(bool)
end

--[[
    设置按钮变灰,并且确定按钮是否可以点击
    @param:enable_touch 按钮是否可以点击,默认是不给点的,有一些特殊需求需要灰掉按钮,但是又可以点击才需要设置
]]
function CustomButton:setGrayAndUnClick(bool, enable_touch,color)
    setChildUnEnabled(bool, self:getRoot())

    enable_touch = enable_touch or TRUE
    local color = color or Config.ColorData.data_color4[1]
    if enable_touch == TRUE then
        if not tolua.isnull(self:getButton())then
            self:getButton():setTouchEnabled(not bool)
        end
    end

    if bool then
        if not tolua.isnull(self:getLabel()) then
            self:getLabel():setTextColor(color)
        end
    else
        if self.font_color then
            if not tolua.isnull(self:getLabel()) then
                self:getLabel():setColor(self.font_color)
            end
            return
        end
        if self.font_color4 then
            if not tolua.isnull(self:getLabel()) then
                self:getLabel():setTextColor(self.font_color4)
            end
            return
        end
        if not tolua.isnull(self:getLabel()) then
            self:getLabel():setTextColor(Config.ColorData.data_color4[1])
        end
    end
end

function CustomButton:setLocalZOrder(order)
    self.layout:setLocalZOrder(order)
end

function CustomButton:setGlobalZOrder(order)
    self.layout:setGlobalZOrder(order)
end

function CustomButton:addToParent(parent)
    self.parent_wnd = parent
    if self.layout:getParent() then
        self.layout:removeFromParent()
    end
    self.parent_wnd:addChild(self.layout)

end
function CustomButton:addChild(child)
    if child~=nil then
      self.layout:addChild(child);
    end
end

function CustomButton:setPosition(x, y)
    self.layout:setPosition(cc.p(x, y))
end

function CustomButton:setPositionY(y)
	self.layout:setPositionY(y)
end

function CustomButton:setPositionX(x)
  self.layout:setPositionX(x)
end  

function CustomButton:setScaleX(x)
    self.layout:setScaleX(x)
end

function CustomButton:setScaleY(y)
    self.layout:setScaleY(y)
end

function CustomButton:getPosition( )
  return self.layout:getPosition()
end

function CustomButton:getPositionX()
    return self.layout:getPositionX()
end

function CustomButton:getPositionY(  )
    return self.layout:getPositionY()
end




function CustomButton:setEnabled(value)
  if self.btn then
    self.btn:setEnabled(value)
  end
end

function CustomButton:__delete()
    self.is_open = false
    self.layout:removeAllChildren()
    self:removeFromParent()
    self.btn_label = nil
    self.btn_image_label = nil
    self.btn = nil
    self.layout = nil
end

function CustomButton:registerEvent()
    self.is_open = true   --存在的状态
    self:registerNodeScriptHandler()
end

function CustomButton:registerNodeScriptHandler()
    local function onNodeEvent(event)
        if "enter" == event then
            if self["onEnter"] then
                self:onEnter()
            end
        elseif "exit" == event then
            self.is_open = false
            if self["onExit"] then
                self:onExit()
            end
        end
    end
    self.layout:registerScriptHandler(onNodeEvent)
end
