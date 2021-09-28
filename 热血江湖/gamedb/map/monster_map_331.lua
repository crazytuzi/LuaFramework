----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[66231] = {pos = { x = 12.10232, y = 6.364571, z = -6.277208 }, mapid = 34023},
	[66241] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 34024},
	[66242] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 34024},
	[66211] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 34021},
	[66212] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 34021},
	[66231] = {pos = { x = -7.494146, y = 6.364571, z = -12.08766 }, mapid = 34023},
	[66232] = {pos = { x = 4.808135, y = 6.364571, z = -18.34769 }, mapid = 34023},
	[66251] = {pos = { x = -29.77403, y = 8.989296, z = 50.54208 }, mapid = 34025},
	[66252] = {pos = { x = -29.53117, y = 9.205496, z = 45.87045 }, mapid = 34025},
	[66253] = {pos = { x = -29.36366, y = 9.300002, z = 55.95007 }, mapid = 34025},
	[66254] = {pos = { x = -26.55258, y = 8.989296, z = 52.46903 }, mapid = 34025},
	[66255] = {pos = { x = -25.70449, y = 8.989296, z = 48.203 }, mapid = 34025},
	[66271] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 34027},
	[66272] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 34027},
	[66281] = {pos = { x = 12.10232, y = 6.364571, z = -6.277208 }, mapid = 34028},
	[66311] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 34031},
	[66312] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 34031},
	[66321] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 34032},
	[66322] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 34032},
	[66331] = {pos = { x = -7.494146, y = 6.364571, z = -12.08766 }, mapid = 34033},
	[66351] = {pos = { x = -29.77403, y = 8.989296, z = 50.54208 }, mapid = 34035},
	[66352] = {pos = { x = -29.53117, y = 9.205496, z = 45.87045 }, mapid = 34035},
	[66353] = {pos = { x = -29.36366, y = 9.300002, z = 55.95007 }, mapid = 34035},
	[66354] = {pos = { x = -26.55258, y = 8.989296, z = 52.46903 }, mapid = 34035},
	[66355] = {pos = { x = -25.70449, y = 8.989296, z = 48.203 }, mapid = 34035},
	[66356] = {pos = { x = -20.74175, y = 8.989296, z = 58.0972 }, mapid = 34035},
	[66361] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 34036},
	[66362] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 34036},
	[66371] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 34037},
	[66372] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 34037},
	[66381] = {pos = { x = -7.494146, y = 6.364571, z = -12.08766 }, mapid = 34038},
	[66201] = {pos = { x = -29.38561, y = 8.989296, z = 51.13597 }, mapid = 34020},
	[66202] = {pos = { x = -30.30107, y = 8.789295, z = 45.60909 }, mapid = 34020},
	[66203] = {pos = { x = -29.36666, y = 9.118736, z = 57.71917 }, mapid = 34020},
	[66204] = {pos = { x = -35.76587, y = 8.914961, z = 51.73969 }, mapid = 34020},
	[66205] = {pos = { x = -25.19786, y = 8.989296, z = 51.41721 }, mapid = 34020},
	[66221] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 34022},
	[66222] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 34022},
	[66261] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 34026},
	[66262] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 34026},
	[66282] = {pos = { x = 4.808135, y = 6.364571, z = -18.34769 }, mapid = 34028},
	[66291] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 34029},
	[66292] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 34029},
	[66301] = {pos = { x = -29.53116, y = 8.989296, z = 51.40447 }, mapid = 34030},
	[66302] = {pos = { x = -26.57438, y = 8.898217, z = 42.29333 }, mapid = 34030},
	[66303] = {pos = { x = -24.80078, y = 9.290885, z = 45.12695 }, mapid = 34030},
	[66304] = {pos = { x = -23.93458, y = 8.989296, z = 49.30204 }, mapid = 34030},
	[66305] = {pos = { x = -22.84432, y = 8.989296, z = 54.00835 }, mapid = 34030},
	[66306] = {pos = { x = -20.74175, y = 8.989296, z = 58.0972 }, mapid = 34030},
	[66332] = {pos = { x = 4.808135, y = 6.364571, z = -18.34769 }, mapid = 34033},
	[66341] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 34034},
	[66342] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 34034},
	[66382] = {pos = { x = 4.808135, y = 6.364571, z = -18.34769 }, mapid = 34038},
	[66391] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 34039},
	[66392] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 34039},

};
function get_db_table()
	return map;
end
