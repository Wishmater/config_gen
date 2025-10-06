# Configuration Classes

This document lists all configuration classes marked with `@Config()`.

## Example2


|name|description|type|default|
|--|--|--|--|
|fieldA| documenation comment for fieldA|String||
|fieldB| documenation comment for fieldB|double||
|fieldC||int|1|
|fieldD||bool?|null|
|fieldE||String?|"def"|

## ExampleConfig


|name|description|type|default|
|--|--|--|--|
|fieldA| documenation comment for fieldA|String||
|fieldB| documenation comment for fieldB|double||
|fieldC||int|2|
|fieldD||bool?|null|
|fieldE||String?|"def"|
|example2| Example 2 schema|[Example2](#Example2)||
|example3||[Example2](#Example2)?|null|
|example4| Example 3 schema|List\<Example2Config\>?|null|
|dynamicSchemas||List\<(String, Object)\>||

## EmptyExampleConfig


|name|description|type|default|
|--|--|--|--|
|dynamicSchemas||List\<(String, Object)\>||

