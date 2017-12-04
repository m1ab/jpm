#!/bin/bash

group_name=$1
project_name=$2

projects_dir=~/src
modules="api jpa web ejb rest static war app"
snapshot_version=0.1-SNAPSHOT
author=misha


cross_module_dependencies_ejb="api jpa"
cross_module_dependencies_rest="api ejb jpa"
cross_module_dependencies_war="api ejb jpa"
cross_module_dependencies_web="api"
cross_module_dependencies_app="api jpa web ejb rest static war"

makeRootPomFile() {

cat > $1 << EOF
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>$2</groupId>
    <artifactId>$3-$4</artifactId>
    <packaging>pom</packaging>
    <version>${snapshot_version}</version>

    <name>${3^} Project</name>
    <url>http://</url>

    <properties>
        <data.source>$3DS</data.source>
        <java.version>1.8</java.version>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>junit</groupId>
                <artifactId>junit</artifactId>
                <version>4.12</version>
            </dependency>
            <dependency>
                <groupId>javax</groupId>
                <artifactId>javaee-api</artifactId>
                <version>7.0</version>
            </dependency>
            <dependency>
                <groupId>org.hibernate</groupId>
                <artifactId>hibernate-jpamodelgen</artifactId>
                <version>4.3.10.Final</version>
            </dependency>
            <dependency>
                <groupId>org.jboss.resteasy</groupId>
                <artifactId>resteasy-jaxrs</artifactId>
                <version>3.0.11.Final</version>
            </dependency>
            <dependency>
                <groupId>commons-fileupload</groupId>
                <artifactId>commons-fileupload</artifactId>
                <version>1.3.1</version>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <dependencies>
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>javax</groupId>
            <artifactId>javaee-api</artifactId>
            <scope>provided</scope>
        </dependency>
        <dependency>
            <groupId>org.hibernate</groupId>
            <artifactId>hibernate-jpamodelgen</artifactId>
            <scope>provided</scope>
        </dependency>
        <dependency>
            <groupId>org.jboss.resteasy</groupId>
            <artifactId>resteasy-jaxrs</artifactId>
            <scope>provided</scope>
        </dependency>
        <dependency>
            <groupId>commons-fileupload</groupId>
            <artifactId>commons-fileupload</artifactId>
            <scope>provided</scope>
        </dependency>
    </dependencies>

    <profiles>
        <profile>
            <id>total</id>
            <modules>
EOF

for module in ${modules}
do
cat >> $1 << EOF
                <module>$3-${module}</module>
EOF
done;

cat >> $1 << EOF
            </modules>
        </profile>
    </profiles>

    <scm>
        <connection>scm:git:http://127.0.0.1/dummy</connection>
        <developerConnection>scm:svn:https://127.0.0.1/dummy</developerConnection>
        <tag>HEAD</tag>
        <url>http://127.0.0.1/dummy</url>
    </scm>

    <distributionManagement>
        <repository>
            <id>$3-releases</id>
            <url>http://127.0.0.1/nexus/content/repositories/$3-releases</url>
        </repository>
        <snapshotRepository>
            <id>$3-snapshots</id>
            <url>http://127.0.0.1/nexus/content/repositories/$3-releases</url>
        </snapshotRepository>
    </distributionManagement>

    <repositories>
        <repository>
            <snapshots>
                <enabled>false</enabled>
            </snapshots>
            <id>$3-releases</id>
            <name>$3-releases</name>
            <url>http://127.0.0.1/nexus/content/repositories/$3-releases</url>
        </repository>
    </repositories>

    <build>
        <resources>
            <resource>
                <directory>src/main/resources</directory>
            </resource>
        </resources>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.5.1</version>
                <configuration>
                    <source>\${java.version}</source>
                    <target>\${java.version}</target>
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-source-plugin</artifactId>
                <version>3.0.1</version>
                <executions>
                    <execution>
                        <id>attach-sources</id>
                        <phase>deploy</phase>
                        <goals>
                            <goal>jar-no-fork</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-install-plugin</artifactId>
                <version>2.5.2</version>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-deploy-plugin</artifactId>
                <version>2.7</version>
                <executions>
                    <execution>
                        <id>deploy</id>
                        <phase>deploy</phase>
                        <goals>
                            <goal>deploy</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-release-plugin</artifactId>
                <version>2.5.3</version>
                <configuration>
                    <autoVersionSubmodules>true</autoVersionSubmodules>
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-ejb-plugin</artifactId>
                <version>2.5.1</version>
                <configuration>
                    <ejbVersion>3.1</ejbVersion>
                </configuration>
            </plugin>
        </plugins>
    </build>

</project>
EOF
}

makeAppProfiles() {
cat >> $1 << EOF
    <profiles>
        <profile>
            <id>total</id>
            <dependencies>
EOF

if [ ! -z "$5" ]
then

for dependency in $5
do

dependencyType="jar"
if [ "${dependency}" == "ejb" ]; then dependencyType="ejb"; fi
if [ "${dependency}" == "war" ]; then dependencyType="war"; fi
if [ "${dependency}" == "rest" ]; then dependencyType="war"; fi
if [ "${dependency}" == "static" ]; then dependencyType="war"; fi

cat >> $1 << EOF
                <dependency>
                    <groupId>$2</groupId>
                    <artifactId>$3-${dependency}</artifactId>
                    <version>${snapshot_version}</version>
                    <type>${dependencyType}</type>
                </dependency>
EOF
done;

fi;

cat >> $1 << EOF
            </dependencies>
            <build>
                <plugins>
                    <plugin>
                        <groupId>org.apache.maven.plugins</groupId>
                        <artifactId>maven-ear-plugin</artifactId>
                        <version>2.10.1</version>
                        <configuration>
                            <earName>$3-$4</earName>
                            <defaultLibBundleDir>lib</defaultLibBundleDir>
                            <applicationName>${3^} Application</applicationName>
                            <description>${3^} Enterprise Application</description>
                            <packagingExcludes />
                            <modules>
EOF

if [ ! -z "$5" ]
then

for dependency in $5
do

moduleType="jarModule"
contextRoot=""
if [ "${dependency}" == "ejb" ]; then moduleType="ejbModule"; fi
if [ "${dependency}" == "war" ]; then moduleType="webModule"; contextRoot="/"; fi
if [ "${dependency}" == "rest" ]; then moduleType="webModule"; contextRoot="/api"; fi
if [ "${dependency}" == "static" ]; then moduleType="webModule"; contextRoot="/data"; fi

cat >> $1 << EOF
                                <${moduleType}>
                                    <groupId>$2</groupId>
                                    <artifactId>$3-${dependency}</artifactId>
EOF

if [ ! -z "${contextRoot}" ]
then
cat >> $1 << EOF
                                    <contextRoot>${contextRoot}</contextRoot>
EOF
fi

cat >> $1 << EOF
                                </${moduleType}>
EOF
done;

fi;

cat >> $1 << EOF
                            </modules>
                        </configuration>
                    </plugin>

                    <!--создание build.properties-->
                    <plugin>
                        <groupId>org.codehaus.mojo</groupId>
                        <artifactId>buildnumber-maven-plugin</artifactId>
                        <version>1.4</version>
                        <executions>
                            <execution>
                                <id>buildnumber</id>
                                <phase>validate</phase>
                                <goals>
                                    <goal>create</goal>
                                </goals>
                            </execution>
                        </executions>
                        <configuration>
                            <format>{0,number}</format>
                            <items>
                                <item>buildNumber</item>
                            </items>
                            <doCheck>false</doCheck>
                            <doUpdate>false</doUpdate>
                            <revisionOnScmFailure>unknownbuild</revisionOnScmFailure>
                        </configuration>
                    </plugin>

                    <!--изменение persistence.xml-->
                    <plugin>
                        <groupId>com.google.code.maven-replacer-plugin</groupId>
                        <artifactId>replacer</artifactId>
                        <configuration>
                            <file>\${basedir}/src/main/application/META-INF/persistence.xml</file>
                            <outputFile>\${project.build.directory}/\${project.artifactId}-\${project.version}/META-INF/persistence.xml</outputFile>
                            <replacements>
                                <replacement>
                                    <token>\#dataSource#</token>
                                    <value>\${data.source}</value>
                                </replacement>
                                <replacement>
                                    <token>\#hbm2ddl_type#</token>
                                    <value>update</value>
                                </replacement>
                            </replacements>
                        </configuration>
                    </plugin>
                </plugins>
            </build>
        </profile>
    </profiles>
EOF
}

makeModulePomFile() {
dependencies=""
packaging="jar"
if [ "$4" == "ejb" ]; then dependencies=${cross_module_dependencies_ejb}; packaging="ejb"; fi
if [ "$4" == "rest" ]; then dependencies=${cross_module_dependencies_rest}; packaging="war"; fi
if [ "$4" == "static" ]; then packaging="war"; fi
if [ "$4" == "war" ]; then dependencies=${cross_module_dependencies_war}; packaging="war"; fi
if [ "$4" == "web" ]; then dependencies=${cross_module_dependencies_web}; fi
if [ "$4" == "app" ]; then dependencies=${cross_module_dependencies_app}; packaging="ear"; fi

cat > $1 << EOF
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>$3-parent</artifactId>
        <groupId>$2</groupId>
        <version>${snapshot_version}</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>$3-$4</artifactId>
    <packaging>${packaging}</packaging>
    <name>${3^} ${4^} Module</name>

EOF

if [ "$4" == "app" ]
then
    makeAppProfiles $1 $2 $3 $4 "${dependencies}"
else
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
fi

cat >> $1 << EOF

</project>
EOF
}



makeBeansXmlFile() {
cat > $1 << EOF
<?xml version="1.0" encoding="UTF-8"?>
<beans
        xmlns="http://xmlns.jcp.org/xml/ns/javaee"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee
                      http://xmlns.jcp.org/xml/ns/javaee/beans_1_1.xsd"
        bean-discovery-mode="all">
</beans>
EOF
}

makePackageInfoFile() {
cat > $1 << EOF
/**
 * Package $2.$3
 *
 * Created by ${author} on $(date '+%d.%m.%Y').
 */
package $2.$3;
EOF
}


printHelp() {
cat << EOF
    Usage: jpm.sh <group-name> <project-name>
    Example: jpm.sh ru.company.project project
EOF
}

createTreeModule() {
module_dir=${projects_dir}/$2/$2-$3
if [ "$3" == "app" ]
then
    the_dir=${module_dir}/src/main/application/META-INF
    mkdir -p ${the_dir}
    cat > ${the_dir}/persistence.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<persistence xmlns="http://xmlns.jcp.org/xml/ns/persistence"
             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
             xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/persistence http://xmlns.jcp.org/xml/ns/persistence/persistence_2_1.xsd"
             version="2.1">
    <persistence-unit name="$2PU" transaction-type="JTA">
        <provider>org.hibernate.ejb.HibernatePersistence</provider>
        <jta-data-source>java:jboss/datasources/$2DS</jta-data-source>

        <!-- Put your classes here -->
        <!--<class>$1.jpa.Example</class>-->

        <exclude-unlisted-classes/>

        <properties>
            <property name="hibernate.generate_statistics" value="false"/>
            <property name="hibernate.hbm2ddl.auto" value="update"/>
            <property name="hibernate.show_sql" value="false"/>
            <property name="hibernate.format_sql" value="false"/>
            <property name="use_sql_comments" value="false"/>
            <property name="org.hibernate.envers.store_data_at_delete" value="true"/>
            <property name="hibernate.listeners.envers.autoRegister" value="false"/>
            <!-- <property name="hibernate.dialect" value="$1.api.dialect.PostgresqlExtensionsDialect"/> -->
        </properties>
    </persistence-unit>

</persistence>

EOF
    the_dir=${module_dir}/src/main/resources/META-INF
    mkdir -p ${the_dir}
    cat > ${the_dir}/beans.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://java.sun.com/xml/ns/javaee"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:s="urn:java:ee"
	xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://docs.jboss.org/cdi/beans_1_0.xsd">

</beans>
EOF

else

if [ "$3" == "static" ]
then
    the_dir=${module_dir}/src/main/webapp
    mkdir -p ${the_dir}/css
    cat > ${the_dir}/css/page.css << EOF
html {
    position: relative;
    min-height: 100%;
}
EOF
    mkdir -p ${the_dir}/js
    cat > ${the_dir}/js/test.js << EOF
//js
EOF
    cat > ${the_dir}/test.html << EOF
<!DOCTYPE html>
<html lang="ru">
<head>
<meta charset="utf-8">
<title>$3</title>
</head>
<body>

<a href='http://mizhgan.com' style='text-decoration: none; color: #555'>
<pre>
 \\\\\¡¡
[(°¿°)] MIZHGAN.COM
</pre></a>
<hr>

<p>Hey, do you like <code>jpm.sh</code></p>
<hr>

</body>
</html>
EOF

else
    package_name=$(echo $1 |sed 's/\./\//g')
    the_dir=${module_dir}/src/main/java/${package_name}/$3
    mkdir -p ${the_dir}
    echo "package $1.$3;" > ${the_dir}/package-info.java
    the_dir=${module_dir}/src/main/resources/META-INF
    mkdir -p ${the_dir}
    cat > ${the_dir}/beans.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://java.sun.com/xml/ns/javaee"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:s="urn:java:ee"
	xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://docs.jboss.org/cdi/beans_1_0.xsd">

</beans>
EOF
    the_dir=${module_dir}/src/test/java/${package_name}/test/$3
    mkdir -p ${the_dir}
    echo "package $1.test.$3;" > ${the_dir}/package-info.java
    the_dir=${module_dir}/src/test/resources/META-INF
    mkdir -p ${the_dir}
    cat > ${the_dir}/beans.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://java.sun.com/xml/ns/javaee"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:s="urn:java:ee"
	xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://docs.jboss.org/cdi/beans_1_0.xsd">

</beans>
EOF
fi
fi

if [ "$3" == "rest" ] || [ "$3" == "static" ] || [ "$3" == "war" ]
then
    the_dir=${module_dir}/src/main/webapp/WEB-INF
    mkdir -p ${the_dir}
    cat > ${the_dir}/web.xml << EOF
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee
		 http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd"
         version="3.1">

</web-app>
EOF
    cat > ${the_dir}/jboss-web.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<jboss-web>
    <virtual-host>default-host</virtual-host>
</jboss-web>
EOF
fi

    makeModulePomFile ${module_dir}/pom.xml $1 $2 $3

}

createTreeStructure() {
    for module in ${modules}; do createTreeModule $1 $2 ${module}; done;
    makeRootPomFile ${projects_dir}/$2/pom.xml $1 $2 parent
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
    echo Exit 1
    exit 1;
fi

if [ -f "${project_dir}" ]
  then
    echo "File with the name [${project_dir}] exists"
    echo Exit 1
    exit 1;
fi

echo "Creating project structure for project [${project_name}]...."
createTreeStructure ${group_name} ${project_name}
echo Done