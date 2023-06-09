function formatResponse(status, result) {
    if (status === 0) {
        return {
            errorMessage: result
        }
    } else {
        return {
            result: result
        };
    }
}

module.exports = {
    formatResponse
};
