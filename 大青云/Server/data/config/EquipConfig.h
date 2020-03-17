

#ifndef _mars_equip_config_
#define _mars_equip_config_

#include <string>
#include <unordered_map>

#include <vector>
using namespace std;
namespace mars
{
	struct SEquipConfig
	{
		int id;	//装备ID;
		std::string name;	//装备名称;
		std::string comment;	//备注说明;
		int main;	//大类;
		int quality;	//品质;
		int priority;	//排序优先级;
		int vocation;	//需求职业;
		bool can_use;	//是否可穿戴;
		std::string icon;	//图标id;
		int groupId;	//所属套装;
		int extraGroupId;	//所属套装;
		int null;	//所属套装;
		int pos;	//装备位;
		int sex;	//性别限制;
		int bind;	//使用后绑定类型;
		int level;	//装备等级;
		int needlevel;	//着装等级;
		int step;	//坐骑等阶限制;
		std::string baseAttr;	//装备基础属性;
		bool sell;	//是否出售;
		bool destroy;	//是否丢弃;
		int price;	//售价;
		int guarantee;	//保质期(天);
		int proid;	//升品后id;
		int drop_value;	//道具价值;
		int log;	//是否记log;
		std::string assin_super;	//指定附加;
		std::string decompose;	//分解获得材料;
		std::string assin_supernew;	//指定卓越;
		int star;	//指定星级;
		int des_group;	//指定套装;
		int group_bind;	//套装绑定;
		std::string need_attr;	//属性限制;
	};

	class EquipConfig
	{
	public:
		int Load(const char* path,const char* name);
		int Size();
		SEquipConfig& Get(int i);
	private:
		typedef std::vector<SEquipConfig> CollectionConfigsT;
		CollectionConfigsT m_vConfigs;
	};
}

#endif