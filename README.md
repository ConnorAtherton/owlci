# OwlCI

![Build Status](https://api.travis-ci.org/ConnorAtherton/owlci.svg)

## Running

We use unicorn as the application server. Run `bundle exec unicorn` to start listening
spawn the workers in order to start accepting resquests on port 3000.

## Creating webhooks

Owl requires listening to webhooks from Github to work correctly. To set this up locally,
we use ngrok to configure a tunnel so we can access localhost from the public internet.

Run the following command changing the 3000 for whatever port you chose for the unicorn worker
above.

```
ngrok http -subdomain=owlci 3000
```

Modify the `SITE_URL` field in your `.env` file to use the subdomain you gave ngrok. We use this
value inside the application to configure the webhooks on behalf of users.
