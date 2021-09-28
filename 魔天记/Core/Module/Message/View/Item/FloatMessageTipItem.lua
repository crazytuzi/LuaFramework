FloatMessageTipItem = class("FloatMessageTipItem");

function FloatMessageTipItem:ctor(transform)
    self:Init(transform);
end

function FloatMessageTipItem:Init(transform)
 
	self.transform = transform;
	self._txtLabel = UIUtil.GetChildByName(self.transform, "UILabel", "txtLabel");
	--self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "icon");
    self._imgBg = UIUtil.GetChildByName(self.transform, "UISprite", "bg");
    self._widget = UIUtil.GetComponent(self.transform.gameObject, "UIWidget");
    self._widget.alpha = 0;
    self._widgetAlphaTweenSpeed = 0.4;
    --0µÄ»°´¦ÓÚ¿ÕÏÐ×´Ì¬£¬1±íÊ¾ÕýÔÚ½øÐÐÆ®×ÖµÄ×´Ì¬£¬2ÒÑ¾­Æ®µ½Y=0µÄ×ø±ê´¦ÁË£¬3¿ªÊ¼½øÈëµ¹¼ÆÊ±×´Ì¬£¬4¿ªÊ¼½øÈë×î¸ß´¦µÈ´ýÏú»Ù×´Ì¬
    self.FloatPosState = 0;
    self._waitEndTime = 1;
    self._constPos1Y = 40;
    self._constPos2Y = 80;
    self._defaultBgWidth = 481;

    self._leftTipsNum = 0;
    self._maxY = self._constPos1Y;

	self:Disable();
end

function FloatMessageTipItem:Dispose()

	self.transform = nil;
    --self._imgIcon = nil;
    self._txtLabel = nil;
    self._widget = nil;
end

function FloatMessageTipItem:Update(deltaTime)
	
    if self.FloatPosState > 0 then
        
        if self._widget.alpha < 1 then
            self._widget.alpha = self._widget.alpha + (deltaTime/self._widgetAlphaTweenSpeed);
        end

        local y = self.transform.localPosition.y + self._constPos1Y * (deltaTime/self._widgetAlphaTweenSpeed);

        --¿ªÊ¼½øÈëµ¹¼ÆÊ±×´Ì¬
        if y >= self._constPos1Y and self.FloatPosState == 2 then
            self.FloatPosState = 3;
        end

        if y >= self._maxY then
            self.transform.localPosition = Vector3(0, self._maxY, 0);

            if (self.FloatPosState == 4) and self._leftTipsNum > 1 then
                self:Disable();
            end
            --¿ªÊ¼½øÈë×î¸ß´¦µÈ´ýÏú»Ù×´Ì¬
            if self.FloatPosState == 3 and self._maxY == self._constPos2Y then 
                self.FloatPosState = 4;
            end
        else
            if y >= 0 and self.FloatPosState == 1 then
                --ÒÑ¾­Æ®µ½0µÄ×ø±ê´¦ÁË
                self.FloatPosState = 2;
            end

            self.transform.localPosition = Vector3(0, y, 0);
        end

        --ÉúÃüÖÜÆÚµ¹¼ÆÊ±
        if self.FloatPosState == 3 or self.FloatPosState == 4 then
            self._waitEndTime = self._waitEndTime - deltaTime;
            if self._waitEndTime < 0 then
                self:Disable();
            end
        end
    end
end

function FloatMessageTipItem:UpdateLeftTipsNum(leftTipsNum)

    if leftTipsNum == 1 and self._leftTipsNum <= 0 then

        self._leftTipsNum = leftTipsNum;
        local y = self.transform.localPosition.y;
        if y < 0 then
            self:SetMaxY(true);
        end;

    elseif leftTipsNum > 1 and self._leftTipsNum == 1 then

        self._leftTipsNum = leftTipsNum;
    end
end

function FloatMessageTipItem:Enable()
    self._widget.alpha = 0;
    --³õÊ¼»¯³öÉúÎ»ÖÃ
    self.transform.localPosition = Vector3(0, -40, 0);
    self._waitEndTime = 1;
    self.transform.gameObject:SetActive(true);
end

function FloatMessageTipItem:Disable()
    self.FloatPosState = 0;
    self.transform.gameObject:SetActive(false);
end

--ÉèÖÃµ±Ç°ÐÅÏ¢µÄ×î¸ßµã
function FloatMessageTipItem:SetMaxY(isMax80)
    if isMax80 then
        self._maxY = self._constPos2Y;
    else
        self._maxY = self._constPos1Y;
    end
end

--isItemTipsType = false or nil¾ÍÊÇ±íÊ¾´«Í³µÄµ¥´¿tips£¬²»ÊÇ»ñµÃÎïÆ·ÌáÊ¾£¬·´Ö®isItemTipsType = true¾ÍÊÇ
function FloatMessageTipItem:Show(data, leftTipsNum)

    self.data = data;
	self:Enable();
    self._leftTipsNum = leftTipsNum;
    
    self:SetMaxY(self._leftTipsNum > 0);

    local txt = "";
	if data.f then
        --Èç¹ûÕâ¸öformat²»Îª¿Õ´ú±í¾ÍÊÇÆÕÍ¨µÄtips
		txt = LanguageMgr.ApplyFormat(data.f, data.p, true);
        
	elseif data.m then
		txt = data.m;
        --self._imgIcon.gameObject:SetActive(false);
        
    elseif data.l then
		txt = LanguageMgr.Get(data.l, data.p, true);
        --self._imgIcon.gameObject:SetActive(false);
        
	end

    if data.c then
        txt = LanguageMgr.GetColor(data.c, txt);
    end

	self._txtLabel.text = txt;
    --[[
    --Ìí¼Ó±³¾°¿í¶È×ÔÊÊÓ¦¹¦ÄÜ
    local textSize = self._txtLabel:GetTextSize(txt, true);
    if textSize.x > self._defaultBgWidth then
        self._imgBg.width = textSize.x + 30;
    else
        self._imgBg.width = self._defaultBgWidth;
    end
    ]]
    self.FloatPosState = 1;
end

