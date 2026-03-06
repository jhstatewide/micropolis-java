When finishing a code task in this project:
1) Run `ant` to ensure the project compiles and jar packaging succeeds.
2) If build-related/resource changes were made, run targeted Ant tasks as needed (`ant clean`, `ant dist`, `ant javadoc`).
3) If runtime behavior changed, smoke-test by launching `java -jar micropolisj.jar`.
4) There is no obvious dedicated automated test suite in the repository; use compile + runtime smoke checks as baseline verification.
5) Review diffs for legacy style consistency and Java 1.6 compatibility constraints from `build.xml`.