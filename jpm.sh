
group_name=$1
project_name=$2

projects_dir=~/src
modules="api app ejb jpa rest war web"

makePomFile() {
echo > $1 <<< EOF
"<?xml version="1.0" encoding="UTF-8"?>"
"<project xmlns=\"http://maven.apache.org/POM/4.0.0\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd\">"
"    <parent>"
"        <artifactId>discount-parent</artifactId>"
"        <groupId>ru.rbt.discount</groupId>"
"        <version>1.3-SNAPSHOT</version>"
"    </parent>"
"    <modelVersion>4.0.0</modelVersion>"
"    "
"    <artifactId>discount-api</artifactId>"
"    <packaging>jar</packaging>"
"    <name>Discount API Module</name>"
"    "
"</project>"
EOF
}

printHelp() {
    echo "    Usage: jpm.sh <group-name> <project-name>"
    echo "    Example: jpm.sh ru.company.project project"
}

createTreeModule() {
    package_name=$(echo $1 |sed 's/\./\//g')
    module_dir=${projects_dir}/$2/$2-$3
    the_dir=${module_dir}/src/main/java/${package_name}/$3
    mkdir -p ${the_dir}
    the_dir=${module_dir}/src/main/resources/
    mkdir -p ${the_dir}
    the_dir=${module_dir}/src/test/java/${package_name}/test/$3
    mkdir -p ${the_dir}
    makePomFile ${module_dir}/pom.xml
}

createTreeStructure() {
    for module in ${modules}; do createTreeModule $1 $2 ${module}; done;
    makePomFile ${projects_dir}/$2/pom.xml
}



if [ -z "$group_name" ]
  then
    echo "Group name not set"
    printHelp
    exit 1;
fi

if [ -z "$project_name" ]
  then
    echo "Project name not set"
    printHelp
    exit;
fi

project_dir="${projects_dir}/${project_name}"

if [ -d "${project_dir}" ]
  then
    echo "Directory with the name [${project_dir}] exists"
fi

if [ -f "${project_dir}" ]
  then
    echo "File with the name [${project_dir}] exists"
fi

echo "Creating project structure for project [${project_name}]...."
createTreeStructure ${group_name} ${project_name}