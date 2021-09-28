DebugWindow =BaseClass()
function DebugWindow:__init()
	self.URL = "ui://0g1b4npuks3k2";

	self.ui = UIPackage.CreateObject("Sys","DebugWindow");

	
	self.frame = self.ui:GetChildAt(0)
end
function DebugWindow:__delete()
	if self.ui then
		self.ui:Dispose()
	end
	self.ui = nil
end