import { render } from '@testing-library/react';
import ExampleComponent from '../components/ExampleComponent';

test('renders without crashing', () => {
    render(<ExampleComponent />);
});
