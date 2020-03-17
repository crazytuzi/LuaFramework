

#ifndef _mars_stren_config_
#define _mars_stren_config_

#include <string>
#include <unordered_map>

#include <vector>
using namespace std;
namespace mars
{
	struct SStrenConfig
	{
		int level;	//星级id;
		int type;	//强化类型;
		int itemId;	//道具id;
		int itemNum;	//道具数量;
		int yuanbaoNum;	//元宝;
		int gold;	//游戏币数量;
		int maxVal;	//进度上限;
		std::string weights;	//权重段;
		std::string rand1;	//段1进度范围;
		std::string rand2;	//段2进度范围;
		int extremeRate;	//极致强化成功率;
		std::string openstar;	//开星道具，数量;
		int keepItem;	//掉级保护道具;
		int keepNum;	//保护道具数量;
		int DropRate;	//失败掉星概率;
		int DropWeight1;	//掉1星权重;
		int DropWeight2;	//掉2星权重;
		int DropWeight3;	//掉3星权重;
		int DropWeight4;	//掉4星权重;
	};

	class StrenConfig
	{
	public:
		int Load(const char* path,const char* name);
		int Size();
		SStrenConfig& Get(int i);
	private:
		typedef std::vector<SStrenConfig> CollectionConfigsT;
		CollectionConfigsT m_vConfigs;
	};
}

#endif