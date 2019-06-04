exports.wrapper = function (workflowContext) {
    'use strict';

    const contextResult = function (context) {
        return {
            'workflowName': context.workflow.name,
            'actionStatus': context.actions.GetMessagesFromTopicSubscription.outputs.status
        };
    };

    return contextResult(workflowContext);
};
