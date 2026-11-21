#!/usr/bin/env bats

@test "a fresh Postgres cluster bootstraps with the app user's generated password" {
    rendered="$BATS_TEST_TMPDIR/init.yaml"
    helm template pg "$BATS_TEST_DIRNAME/../packages/apps/postgres" \
        --namespace tenant-test --set-json '_cluster={"scheduling":{}}' --set-json 'users={"app":{}}' \
        --show-only templates/init-script.yaml > "$rendered"

    app=$(yq --exit-status 'select(.kind == "Secret" and .metadata.name == "pg-credentials").stringData.app' "$rendered")
    owner=$(yq --exit-status 'select(.kind == "Secret" and .metadata.name == "pg-app-owner").stringData.password' "$rendered")
    [[ -n "$app" && "$app" == "$owner" ]]
}
