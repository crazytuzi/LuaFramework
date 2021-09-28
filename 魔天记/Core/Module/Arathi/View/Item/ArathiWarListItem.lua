require "Core.Module.Common.UIItem"

ArathiWarListItem = UIItem:New();

function ArathiWarListItem:_Init()
    self._imgBG = UIUtil.GetChildByName(self.transform, "UISprite", "imgBG");
	self._imgCareer = UIUtil.GetChildByName(self.transform, "UISprite", "imgCareer");
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
	self._txtLevel = UIUtil.GetChildByName(self.transform, "UILabel", "txtLevel");
	self._txtPower = UIUtil.GetChildByName(self.transform, "UILabel", "txtPower");
    self._txtKill = UIUtil.GetChildByName(self.transform, "UILabel", "txtKill");
    self._txtHurt = UIUtil.GetChildByName(self.transform, "UILabel", "txtHurt");
    self._txtHelp = UIUtil.GetChildByName(self.transform, "UILabel", "txtHelp");
    self._txtDie = UIUtil.GetChildByName(self.transform, "UILabel", "txtDie");
    self._txtOccupy = UIUtil.GetChildByName(self.transform, "UILabel", "txtOccupy");
    self._txtHonor = UIUtil.GetChildByName(self.transform, "UILabel", "txtHonor");

    self:UpdateItem(self.data);
end

function ArathiWarListItem:_Dispose()
    self._imgBG = nil;
    self._imgCareer = nil;
    self._txtName = nil;
	self._txtLevel = nil;
	self._txtPower = nil;
    self._txtKill = nil;
    self._txtHurt = nil;
    self._txtHelp = nil;
    self._txtDie = nil;
    self._txtOccupy = nil;
    self._txtHonor = nil;
end

function ArathiWarListItem:UpdateItem(data)
    self.data = data;
	if (data and self._imgBG) then
		if (data.camp == 1) then
            self._imgBG.color = Color.New(1,0,0);
        else
            self._imgBG.color = Color.New(1,1,1);
        end
        self._imgCareer.spriteName = "c"..data.k;
        self._txtName.text = data.pn;
        self._txtLevel.text = data.lv;
        self._txtPower.text = data.ft;
        self._txtKill.text = data.kc;
        self._txtHurt.text = data.cb;
        self._txtHelp.text = data.ac;
        self._txtDie.text = data.dc;
        self._txtOccupy.text = data.cpc;
        self._txtHonor.text = data.h;
	end
end
