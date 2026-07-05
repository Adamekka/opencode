export const WorkDoneNotification = async ({ $, client }) => {
  const script = 'display notification "Work is done." with title "opencode" sound name "Glass"'

  return {
    event: async ({ event }) => {
      if (event.type !== "session.idle") return

      try {
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
