# ISO19139 dutch service schema plugin schema plugin

ISO19139 dutch service schema plugin.

## Installing the plugin

### GeoNetwork version to use with this plugin

Use GeoNetwork 4.4. It's not supported in older versions so don't plug it into it!

### Adding the plugin to the source code


The best approach is to add the plugin as a submodule:

1. Use [`add-schema.sh`](https://github.com/geonetwork/core-geonetwork/blob/4.4.x/add-schema.sh) for automatic deployment:

   ```
   ./add-schema.sh iso19139.nl.services.2.0.0 https://github.com/metadata101/iso19139.nl.services.2.0.0 4.4.x
   ```

2. Build the application:

   ```
   mvn clean install -Penv-prod -DskipTests
   ```

3. Once the application is built, the war file contains the schema plugin:

   ```
   cd web
   mvn jetty:run -Penv-dev
   ```

### Deploy the profile in an existing installation

After building the application, it's possible to deploy the schema plugin manually in an existing GeoNetwork installation:

- Copy the content of the folder schemas/iso19139.nl.services.2.0.0/src/main/plugin to `$INSTALL_DIR/geonetwork/WEB-INF/data/config/schema_plugins/iso19139.nl.services.2.0.0`

- Copy the jar file schemas/iso19139.nl.services.2.0.0/target/schema-iso19139.nl.services.2.0.0-4.4.7-SNAPSHOT.jar to `$INSTALL_DIR/geonetwork/WEB-INF/lib`.

If there's no changes to the profile Java code or the configuration (`config-spring-geonetwork.xml`), the jar file is not required to be deployed each time.
