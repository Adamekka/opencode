import type { Plugin } from "@opencode-ai/plugin"

export const Notifications: Plugin = async ({ $, client }) => {
  return {
    event: async ({ event }) => {
      const message = {
        "session.idle": "Work is done.",
        "question.asked": "The agent has a question.",
        "permission.asked": "The agent needs permission.",
      }[event.type]
      if (!message) return

      try {
        const script = `display notification ${JSON.stringify(message)} with title "opencode" sound name "Glass"`
        await $`osascript -e ${script}`
      } catch (error) {
        // Notification failures should not interrupt the session that just completed.
        await client.app.log({
          body: {
            service: "work-done-notification",
            level: "warn",
            message: "Failed to send work-done notification",
            extra: {
              error: error instanceof Error ? error.message : String(error),
            },
          },
        })
      }
    },
  }
}
