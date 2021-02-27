# actions-autify-light
Simple GitHub Actions for Autify (https://autify.com/)

## What do this action
This action does the following:

- Kick Autify test-plan specified by ID.
- Wait for execution result.
- Returns an exit code depending on the result.


## Inputs and Outputs this action needs
### Inputs
- `project_id`
    - Your Autify project ID.
    - For example, the project_id for the following URL is `1`.
        - `https://app.autify.com/projects/1/results`
- `testplan_id`
    - Your Autify testplan ID.
    - In order to request executing the test plan `https://app.autify.com/projects/1/test_plans/3` , the testplan ID is `3` .

### Outputs
none.

## Environment variables this action needs
- `AUTIFY_PERSONAL_TOKEN`
    - Your Autify personal access token. To generate or manage tokens, please visit [your account page](https://app.autify.com/settings).

## Other secrets this action needs
none.

## How to use (Example Usage)

```yml
- name: Run Autify TestPlan
  uses: a-know/actions-autify-light@main
  with:
    project_id: ${{ secrets.AUTIFY_PROJECT_ID }}
    testplan_id: ${{ secrets.AUTIFY_TESTPLAN_ID }}
  env:
    AUTIFY_PERSONAL_TOKEN: ${{ secrets.AUTIFY_PERSONAL_TOKEN }}
```
