Global("Locales", {})

function getLocale()
	return Locales[common.GetLocalization()] or Locales["eng"]
end

--------------------------------------------------------------------------------
-- Russian
--------------------------------------------------------------------------------

Locales["rus"]={}
Locales["rus"]["lineM"]="Кол-во мастерства"
Locales["rus"]["lineR"]="Кол-во решимости"
Locales["rus"]["lineB"]="Кол-во беспощадности"
Locales["rus"]["lineCrit"]="Кол-во удачи"
Locales["rus"]["lineDiff"]="Лучше текущих на:"
Locales["rus"]["resM"]="Не посчитано"
Locales["rus"]["resR"]="Не посчитано"
Locales["rus"]["resB"]="Не посчитано"
Locales["rus"]["resDiff"]="Не посчитано"
Locales["rus"]["resCrit"]="Не посчитано"
Locales["rus"]["resType1"]="Не посчитано"
Locales["rus"]["resType2"]="Не посчитано"
Locales["rus"]["resType3"]="Не посчитано"
Locales["rus"]["resType4"]="Не посчитано"
Locales["rus"]["calcButton1"]="Метод 1"
Locales["rus"]["calcButton2"]="Метод 2"
Locales["rus"]["desc"]="Производится расчет оптимального соотношения мастерства, беспощадности, решимости и удачи. Балансируются лишь те что уже вложены в указанные на текущий момент. Подбор господства, стремительности лежит на вас самих(они для каждого класса индивидуальны). Шаг рассчета 20 статов."
Locales["rus"]["amuletInfo"]="*Исходя из качества амулета считается, что он в среднем прибавляет мастерства: "
Locales["rus"]["useShop"]="Посчитать с шопом (+100)"
Locales["rus"]["useOrden"]="Посчитать с орденом (+100р)"
Locales["rus"]["amountOfR"]="Уровень решимости (0-100) : "
Locales["rus"]["useAlhim"]="Посчитать с алхимом (+50)"
Locales["rus"]["useEatR"]="Посчитать с едой (+25р)"
Locales["rus"]["useGuildCrit"]="Посчитать с гильдией (+40у)"
Locales["rus"]["useDoblest"]="Посчитать с доблестью"
Locales["rus"]["useOrnament"]="Посчитать с орнаментами (+48м +48у)"
Locales["rus"]["type1"]="Доля физического урона(%):"
Locales["rus"]["type2"]="Доля стихийного урона(%):"
Locales["rus"]["type3"]="Доля божественного урона(%):"
Locales["rus"]["type4"]="Доля природного урона(%):"
Locales["rus"]["lvlOfArt"]="Уровень Трикветра (0-10) : "
--------------------------------------------------------------------------------
-- English
--------------------------------------------------------------------------------

Locales["eng"]={}
Locales["eng"]["lineM"]="Skill count"
Locales["eng"]["lineR"]="Determination count"
Locales["eng"]["lineB"]="Number of ruthlessness"
Locales["eng"]["lineCrit"]="Amount of luck"
Locales["eng"]["lineDiff"]="Better current on:"
Locales["eng"]["resM"]="Not counted"
Locales["eng"]["resR"]="Not counted"
Locales["eng"]["resB"]="Not counted"
Locales["eng"]["resDiff"]="Not counted"
Locales["eng"]["resCrit"]="Not counted"
Locales["eng"]["resType1"]="Not counted"
Locales["eng"]["resType2"]="Not counted"
Locales["eng"]["resType3"]="Not counted"
Locales["eng"]["resType4"]="Not counted"
Locales["eng"]["calcButton1"]="Method 1"
Locales["eng"]["calcButton2"]="Method 2"
Locales["eng"]["desc"]="An optimal balance of skill, ruthlessness, determination and luck is calculated. Only those that are already invested in the currently specified ones are balanced. The selection of domination and swiftness lies with you (they are for each class are individual). The calculation step is 20 stats. "
Locales["eng"]["amuletInfo"]="* Based on the quality of the amulet, it is believed that it adds skill on average: "
Locales["eng"]["useShop"]="Calculate with shop (+100)"
Locales["eng"]["useOrden"]="Count with the order (+100?)"
Locales["eng"]["amountOfR"]="Determination level (0-100) : "
Locales["eng"]["useAlhim"]="Count with alchem (+50)"
Locales["eng"]["useEatR"]="Calculate with food (+25?)"
Locales["eng"]["useGuildCrit"]="Calculate with guild (+40o)"
Locales["eng"]["useDoblest"]="Calculate with valor"
Locales["eng"]["useOrnament"]="Count with ornaments (+48i +48o)"
Locales["eng"]["type1"]="Percentage of Physical damage(%):"
Locales["eng"]["type2"]="Proportion of Elemental damage(%):"
Locales["eng"]["type3"]="Divine Damage Percentage(%):"
Locales["eng"]["type4"]="Share of Natural damage(%):"
Locales["eng"]["lvlOfArt"]="Triquetra level (0-10) : "
