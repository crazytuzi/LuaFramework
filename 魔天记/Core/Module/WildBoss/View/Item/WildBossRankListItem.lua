require "Core.Module.Common.UIItem"

WildBossRankListItem = UIItem:New();

function WildBossRankListItem:_Init()
	self._txtBossName = UIUtil.GetChildByName(self.transform, "UILabel", "txtBossName");
	self._txtPlayerName = UIUtil.GetChildByName(self.transform, "UILabel", "txtPlayerName");
	self._txtHurt = UIUtil.GetChildByName(self.transform, "UILabel", "txtHurt");
	self:UpdateItem(self.data);
end

function WildBossRankListItem:_Dispose()
    self._txtBossName = nil;
	self._txtPlayerName = nil;
	self._txtHurt = nil;
    self.data = nil;
end

function WildBossRankListItem:UpdateItem(data)
	self.data = data;
	if (data and self._txtBossName) then
		self._txtBossName.text = data.mn
		if (data.isOpen == false) then
			self._txtPlayerName.color = Color.New(255 / 0xff, 75 / 0xff, 75 / 0xff);
		else
			self._txtPlayerName.color = Color.New(156 / 0xff, 255 / 0xff, 148 / 0xff);
		end
		if (data.kn ~= "") then
			self._txtPlayerName.text = data.kn			
		else
			self._txtPlayerName.text = "--";			
		end
		if (data.h > 0) then			
			self._txtHurt.text = data.h
		else
			if (data.isOpen == false) then
				self._txtHurt.text = "";
			else
				self._txtHurt.text = "--";
			end
		end
	end
end
