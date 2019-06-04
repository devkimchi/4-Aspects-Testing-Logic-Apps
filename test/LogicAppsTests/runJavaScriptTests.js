'use strict';

let assert = require('assert');
let action = require('../../src/LogicApps/runJavaScript.js');

describe('RunJavaScript action Tests', () => {
    let context = {
        'workflow': {
            'name': 'abc'
        },
        'actions': {
            'GetMessagesFromTopicSubscription': {
                'outputs': {
                    'status': 'Succeeded'
                }
            }
        }
    };

    it('Should return workflow name', () => {
        let result = action.wrapper(context);

        assert.equal(result.workflowName, 'abc');
    });

    it('Should return content type from action', () => {
        let result = action.wrapper(context);

        assert.equal(result.actionStatus, 'Succeeded');
    });
});
