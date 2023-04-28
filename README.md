# IDS-project

The goal of the solved project is the design and implementation of a relational database on the chosen topic. The project is solved in teams of two.

The project consists of four parts. All submitted SQL scripts must be intended for the database management system, Oracle 12c, and must allow repeated calls, i.e. deletion and re-creation, or even rewriting, of objects in the database and their data (it is okay if unsuccessful attempts occur during the first call of the script about the deletion of non-existent database objects).

### First Part: 4/5
### Second Part: 4/5
### Third Part: 5/5
### Fourth Part: -/19
      
#### TODO: Fourth part
- [x] vytvoření alespoň dvou netriviálních databázových triggerů vč. jejich předvedení,
- [X] vytvoření alespoň dvou netriviálních uložených procedur vč. jejich předvedení, ve kterých se musí (dohromady) vyskytovat alespoň jednou kurzor, ošetření výjimek a použití proměnné s datovým typem odkazujícím se na řádek či typ sloupce tabulky (table_name.column_name%TYPE nebo table_name%ROWTYPE),
- [X] explicitní vytvoření alespoň jednoho indexu tak, aby pomohl optimalizovat zpracování dotazů, přičemž musí být uveden také příslušný dotaz, na který má index vliv, a v dokumentaci popsán způsob využití indexu v tomto dotazy (toto lze zkombinovat s EXPLAIN PLAN, vizte dále),
- [x] alespoň jedno použití EXPLAIN PLAN pro výpis plánu provedení databazového dotazu se spojením alespoň dvou tabulek, agregační funkcí a klauzulí GROUP BY, přičemž v dokumentaci musí být srozumitelně popsáno, jak proběhne dle toho výpisu plánu provedení dotazu, vč. objasnění použitých prostředků pro jeho urychlení (např. použití indexu, druhu spojení, atp.), a dále musí být navrnut způsob, jak konkrétně by bylo možné dotaz dále urychlit (např. zavedením nového indexu), navržený způsob proveden (např. vytvořen index), zopakován EXPLAIN PLAN a jeho výsledek porovnán s výsledkem před provedením navrženého způsobu urychlení,
- [X(doplnit)] definici přístupových práv k databázovým objektům pro druhého člena týmu,
- [X(hadam)] vytvoření alespoň jednoho materializovaného pohledu patřící druhému členu týmu a používající tabulky definované prvním členem týmu (nutno mít již definována přístupová práva), vč. SQL příkazů/dotazů ukazujících, jak materializovaný pohled funguje,
- [X] vytvoření jednoho komplexního dotazu SELECT využívajícího klauzuli WITH a operátor CASE. V poznámce musí být uvedeno, jaká data dotaz získává.
