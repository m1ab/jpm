
group_name=$1
project_name=$2

projects_dir=~/src
modules="api app ejb jpa rest war web"
snapshot_version=0.1-SNAPSHOT

cross_module_dependencies_ejb="api jpa"
cross_module_dependencies_rest="api ejb jpa"
cross_module_dependencies_war="api ejb jpa"
cross_module_dependencies_web="api"
cross_module_dependencies_app="api ejb jpa war web"

makeModulePomFile() {
dependencies=""
packaging="jar"
if [ "$4" == "ejb" ]; then dependencies=${cross_module_dependencies_ejb}; packaging="ejb"; fi
if [ "$4" == "rest" ]; then dependencies=${cross_module_dependencies_rest}; fi
if [ "$4" == "war" ]; then dependencies=${cross_module_dependencies_war}; packaging="war"; fi
if [ "$4" == "web" ]; then dependencies=${cross_module_dependencies_web}; fi
if [ "$4" == "app" ]; then dependencies=${cross_module_dependencies_app}; packaging="pom"; fi

cat > $1 << EOF
<?xml version="1.0" encoding=\"UTF-8\"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>$3-parent</artifactId>
        <groupId>$2</groupId>
        <version>${snapshot_version}</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>$3-$4</artifactId>
    <packaging>${packaging}</packaging>
    <name>$3-$4</name>

EOF

if [ ! -z "${dependencies}" ]
then
echo "    <dependencies>" >> $1
for dependency in ${dependencies}
do
cat >> $1 << EOF
        <dependency>
            <groupId>$2</groupId>
            <artifactId>$3-${dependency}</artifactId>
            <version>${snapshot_version}</version>
            <scope>provided</scope>
        </dependency>
EOF
done;
echo "    </dependencies>" >> $1
fi

cat >> $1 << EOF

</project>
EOF
}

printHelp() {
cat << EOF
    Usage: jpm.sh <group-name> <project-name>
    Example: jpm.sh ru.company.project project
EOF
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
    makeModulePomFile ${module_dir}/pom.xml $1 $2 $3
}

createTreeStructure() {
    for module in ${modules}; do createTreeModule $1 $2 ${module}; done;
#    makePomFile ${projects_dir}/$2/pom.xml $1 $2 parent
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