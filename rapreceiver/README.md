# RAP Receiver Testing

Some simple utilities to simulate the RAP Receiver (aka the CHARITY component). This is for the topic "Internal/Charityfund/Increased".

## Utilities

**`listen`**

On startup, generates a temporary queue name, sets up a queue with that name, subscribes that queue to the "Internal/Charityfund/Increased" topic, and sets up a simple webhook subscription to that queue to receive messages that arrive on it.

Assumes that there's already a simple HTTP service to act as a webhook receiver running as an app called "webhook" on the Cloud Foundry (CF) runtime. It's to the route for this app that the webhook subscription is connected.

Once started, it will display any logs emitted from the webhook receiver.

On shutdown, it will clean up by deleting the webhook subscription and the queue (and implicitly also the queue subscription to the topic).


**`emit`**

Produces a full payload, in JSON, to be sent to the "Internal/Charityfund/Increased" topic.

## Usage

Run the `listen` script in one window, and wait for it to set things up. Then, in a second window, send a message to the topic like this:

```bash
$ ./messaging publish_message_to_topic Internal%2FCharityfund%2FIncreased "$(genpay)"
```

The message should make its way to the topic, thence to the subscribed queue, and then be seen in the webhook receiver log output.
