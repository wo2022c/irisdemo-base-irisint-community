# IRIS Community Demo Base Image (integration)

**WARNING**: This image is used exclusively for demos. We have set SuperUser with the password "sys".

The image includes:
- Java 8
- An APPINT namespace that is Ensemble enabled
- There is an integration production called IRISDemo.Production on it, that is already configured to start automatically with the instance.
- The production has Java Gateway configured
- CSP application for REST Services (/csp/user/rest) as well a dispatcher class named IRISDemo.REST.Dispatcher
- CSP application for SOAP Services (/csp/user/soap)

If you just want to run the instance on your PC, make sure you have docker installed on your machine and run the following command:

```bash
docker run -it --rm -p 1972:1972 -p 52773:52773 --name iriscontainer --init intersystemsdc/irisdemo-base-irisint-community:latest
```

Then open the System Manager Portal on http://localhost:52773/csp/sys/UtilHome.csp

Use the username **SuperUser** and the password **sys**. The original IRIS Community image from InterSystems would require you to change the password on your first login. As this image is built for demos, we have disabled this and have left the password **sys**.

If you want to open an IRIS Session on your running IRIS container, just run:

```bash
docker exec -it iriscontainer iris session iris
```

Enjoy!