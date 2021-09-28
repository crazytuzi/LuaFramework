local sspringfestivallist = require "protocoldef.knight.gsp.springfestival.sspringfestivallist"
function sspringfestivallist:process()
	for k,v in pairs(self.springfestivalinfos) do
		local SpringEntranceDlg = require "ui.spring.springentrancedlg"
		SpringEntranceDlg.getInstance():RefreshList(self.springfestivalinfos)
	end
end