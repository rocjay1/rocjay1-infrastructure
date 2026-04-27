export default {
  async fetch(request, env) {
    return new Response("Feed Aggregator Worker");
  },
  async scheduled(event, env, ctx) {
    console.log("Cron trigger executed");
  }
};
