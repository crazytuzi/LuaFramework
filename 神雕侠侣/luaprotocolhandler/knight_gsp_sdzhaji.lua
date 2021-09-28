local sreqshendiaoroad = require "protocoldef.knight.gsp.sdzhaji.sreqshendiaoroad"
function sreqshendiaoroad:process()

	local SDZhiLuDlg = require "ui.sdzhaji.sdzhiludlg"

	SDZhiLuDlg.OnSReqShenDiaoRoad(self)
end

local sreqshendiaoroad = require "protocoldef.knight.gsp.sdzhaji.staskstate"
function sreqshendiaoroad:process()

	local SDZhuanJiDlg = require "ui.sdzhaji.sdzhuanjidlg"
	local SDZhangJieDlg = require "ui.sdzhaji.sdzhangjiedlg"
	
	if self.flag == 1 then
		SDZhangJieDlg.OnSTaskState(self)
	elseif self.flag == 2 then
		SDZhuanJiDlg.OnSTaskState(self)
	end
end