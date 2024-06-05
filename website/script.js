document.addEventListener('DOMContentLoaded', function () {
    const updateVisitorCount = async () => {
        const spinner = document.getElementById('loadingSpinner');
        try {
            const url = 'https://cv-api.az.macro-c.com/api/getvisitor';
            // Check if we already have a count for this session
            const storedCount = sessionStorage.getItem('currentVisitorCount');
            if (storedCount) {
                document.getElementById('visitorCount').textContent = storedCount;
                return; // Exit if we already have a count, avoiding an unnecessary API call
            }
            // If no count is stored, fetch it from the API
            spinner.style.display = 'block'; // Show spinner
            const response = await fetch(url);
            spinner.style.display = 'none'; // Hide spinner
            if (response.ok) {
                const data = await response.text();
                document.getElementById('visitorCount').textContent = data;
                sessionStorage.setItem('currentVisitorCount', data); // Store the fetched count
            } else {
                console.error('Failed to fetch visitor count:', response.statusText);
            }
        } catch (error) {
            spinner.style.display = 'none'; // Hide spinner
            console.error('Error fetching visitor count:', error);
        }
    };
    updateVisitorCount();
});
